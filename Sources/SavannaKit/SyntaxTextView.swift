//
//  SyntaxTextView.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 23/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import Lioness
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

private enum InitMethod {
	case coder(NSCoder)
	case frame(CGRect)
}

#if os(macOS)
	
	extension NSView {
		
		var backgroundColor: Color? {
			set {
				layer?.backgroundColor = newValue?.cgColor
			}
			get {
				if let color = layer?.backgroundColor {
					return Color(cgColor: color)
				} else {
					return nil
				}
			}
		}
		
	}
	
	extension NSTextView {
		
		var text: String! {
			get {
				return string
			}
			set {
				self.string = newValue
			}
		}
		
		var tintColor: Color {
			set {
				insertionPointColor = newValue
			}
			get {
				return insertionPointColor
			}
		}
		
	}
	
#endif

#if os(macOS)

	private class TextViewWrapperView: View {
		
		var textView: InnerTextView?
		
		override public func draw(_ rect: CGRect) {

			Color.black.setFill()

			let gutterRect = CGRect(x: 0, y: 0, width: 20, height: rect.height)
			let path = BezierPath(rect: gutterRect)
			path.fill()
			
			guard let textView = textView else {
				return
			}
			
			let contentHeight = textView.enclosingScrollView!.documentView!.bounds.height
			
			Swift.print("contentHeight: \(contentHeight)")
			let yOffset = self.bounds.height - contentHeight
			
			drawLineNumbers(in: self.bounds, for: textView, flipRects: true, yOffset: yOffset)
			
		}
		
	}
	
#endif

extension TextView {
	
	func paragraphRectForRange(range: Range<String.Index>) -> CGRect {
		
		#if os(macOS)
			let range = self.textStorage!.string.paragraphRange(for: range)
		#else
			let range = self.textStorage.string.paragraphRange(for: range)
		#endif
		
		let start = text.distance(from: text.startIndex, to: range.lowerBound)
		let length = text.distance(from: range.lowerBound, to: range.upperBound)
		
		var nsRange = NSMakeRange(start, length)
		
		let contentAfter = text.substring(from: range.upperBound)
		
		
		let layoutManager: NSLayoutManager
		let textContainer: NSTextContainer
		#if os(macOS)
			layoutManager = self.layoutManager!
			textContainer = self.textContainer!
		#else
			layoutManager = self.layoutManager
			textContainer = self.textContainer
		#endif
		
		nsRange = layoutManager.glyphRange(forCharacterRange: nsRange, actualCharacterRange: nil)
		
		Swift.print(nsRange.toRange()!)
		
		var sectionRect = layoutManager.boundingRect(forGlyphRange: nsRange, in: textContainer)
		//		sectionRect.origin.x += textContainerInset.left
		
		// FIXME: don't use this hack
		// This gets triggered for the final paragraph in a textview if the next line is empty (so the last paragraph ends with a newline)
		if sectionRect.origin.x == 0 {
			sectionRect.size.height -= 22
		}
		
		sectionRect.origin.x = 0
		
		return sectionRect
	}
	
}

private func drawLineNumbers(in rect: CGRect, for textView: InnerTextView, flipRects: Bool = false, yOffset: CGFloat = 0) {
	
	print("=============")
	
	print("textView.bounds.width: \(textView.bounds.width)")

	//		let documentVisibleRect = self.enclosingScrollView?.documentVisibleRect
	
	//		Swift.print(documentVisibleRect)
	
	//		if let prevScrollPosition = prevScrollPosition {
	//
	//			if prevScrollPosition == documentVisibleRect {
	//
	//				super.draw(rect)
	//				return
	//			}
	//		}
	
	//		prevScrollPosition = documentVisibleRect
	//		UIColor.red.setFill()
	//
	
	let range = textView.text.startIndex..<textView.text.endIndex
	
	var paragraphs = [Paragraph]()
	var i = 0
	
	//		let selectedRange = self.selectedRange
	
	//		let stringRange = self.text.range(fromNSRange: selectedRange)
	
	
	//		print(self.text.substring(with: stringRange))
	
//	let contentWidth = 
	
	textView.text.enumerateSubstrings(in: range, options: [.byParagraphs]) { (paragraphContent, paragraphRange, enclosingRange, stop) in
		
		i += 1
		
		var rect = textView.paragraphRectForRange(range: paragraphRange)
		
		print(paragraphContent)
		
		let paragraph = Paragraph(rect: rect, number: i)
		paragraphs.append(paragraph)
		
	}
	
	if textView.text.isEmpty || textView.text.hasSuffix("\n") {
		
		var rect: CGRect
		
		#if os(macOS)
			let gutterWidth = textView.textContainerInset.width
		#else
			let gutterWidth = textView.textContainerInset.left
		#endif
		
		let lineHeight: CGFloat = 22
		
		if let last = paragraphs.last {
			
			rect = CGRect(x: 0, y: last.rect.origin.y + last.rect.height, width: gutterWidth, height: lineHeight)
			
		} else {
			
			rect = CGRect(x: 0, y: 0, width: gutterWidth, height: lineHeight)
			
		}
		
		
		i += 1
		let endParagraph = Paragraph(rect: rect, number: i)
		paragraphs.append(endParagraph)
		
	}
	

	
	#if os(macOS)
		
		if let yOffset = textView.enclosingScrollView?.contentView.bounds.origin.y {
		
			paragraphs = paragraphs.map { (p) -> Paragraph in
				
				var p = p
				p.rect.origin.y -= yOffset
				
//				textView.intrinsicContentSize.height -

				
				return p
			}
		}
		
		
	#endif
	
	if flipRects {
		
		paragraphs = paragraphs.map { (p) -> Paragraph in
			
			var p = p
			p.rect.origin.y = textView.bounds.height - p.rect.height - p.rect.origin.y
			
//			let yOffset = textView.enclosingScrollView!.contentView.bounds.origin.y
//			p.rect.origin.y += yOffset
			
			return p
		}
		
	}
	
	paragraphs = paragraphs.map { (p) -> Paragraph in
		
		var p = p
		p.rect.origin.y += yOffset
		return p
	}
	
	for paragraph in paragraphs {
		
		print(paragraph.rect.debugDescription)
		
		guard paragraph.rect.intersects(rect) else {
			continue
		}
		
		let attr = paragraph.attributedString(for: textView.theme)
		
		attr.draw(in: paragraph.rect)
		
	}
	
}

private class InnerTextView: TextView {
	
	fileprivate lazy var theme: SyntaxColorTheme = {
		return DefaultTheme()
	}()
	
//	var prevScrollPosition: CGRect?
	
//	#if os(iOS)
	override public func draw(_ rect: CGRect) {
		
//		Color.red.setFill()
//		
//		let gutterRect = CGRect(x: 0, y: 0, width: 20, height: 88)
//		
//		let path = BezierPath(rect: gutterRect)
//		path.fill()
//		
		
//		drawLineNumbers(in: rect, for: self)
		super.draw(rect)
	}
//	#endif
	
}

public protocol SyntaxTextViewDelegate: class {
	
	func didChangeText(_ syntaxTextView: SyntaxTextView)
	
}

public class SyntaxTextView: View {

	private let textView: InnerTextView
	
	public weak var delegate: SyntaxTextViewDelegate?
	
	#if os(macOS)
	
	fileprivate let wrapperView = TextViewWrapperView()

	#endif
	
	#if os(iOS)

	public var contentInset: UIEdgeInsets = .zero {
		didSet {
			textView.contentInset = contentInset
			textView.scrollIndicatorInsets = contentInset
		}
	}
	
	public override var tintColor: UIColor! {
		didSet {
			keyboardToolbar.tintColor = tintColor
		}
	}
	
	#else
	
	public var tintColor: NSColor! {
		set {
			textView.tintColor = newValue
		}
		get {
			return textView.tintColor
		}
	}
	
	#endif
	
	override convenience init(frame: CGRect) {
		self.init(.frame(frame))!
	}
	
	public required convenience init?(coder aDecoder: NSCoder) {
		self.init(.coder(aDecoder))
	}
	
	private init?(_ initMethod: InitMethod) {

		textView = InnerTextView(frame: .zero)
		
		switch initMethod {
		case let .coder(coder): super.init(coder: coder)
		case let .frame(frame): super.init(frame: frame)
		}
		
		setup()
	}
	
	#if os(iOS)

	private var keyboardToolbar: UIToolbar!
	
	#endif

	#if os(macOS)

		public let scrollView = NSScrollView()

	#endif
	
	private func setup() {
		
		
		#if os(macOS)
			textView.textContainerInset = NSSize(width: 20, height: 0)
		#else
			textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
			textView.translatesAutoresizingMaskIntoConstraints = false

		#endif
		
		#if os(macOS)

			wrapperView.translatesAutoresizingMaskIntoConstraints = false

			addSubview(wrapperView)
			
			
			
			
			
			scrollView.backgroundColor = .clear
			scrollView.drawsBackground = false
			
			scrollView.contentView.backgroundColor = .clear
			
			scrollView.translatesAutoresizingMaskIntoConstraints = false

			self.addSubview(scrollView)
			scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
			scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
			
			wrapperView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
			wrapperView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
			wrapperView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
			wrapperView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
			
			
			scrollView.borderType = .noBorder
			scrollView.hasVerticalScroller = true
			scrollView.hasHorizontalScroller = false
			
			scrollView.documentView = textView
			
			scrollView.contentView.postsBoundsChangedNotifications = true
			
			NotificationCenter.default.addObserver(self, selector: #selector(didScroll(_:)), name: .NSViewBoundsDidChange, object: scrollView.contentView)
			
			textView.minSize = NSSize(width: 0.0, height: self.bounds.height)
			textView.maxSize = NSSize(width: CGFloat(FLT_MAX), height: CGFloat(FLT_MAX))
			textView.isVerticallyResizable = true
			textView.isHorizontallyResizable = false
			textView.autoresizingMask = .viewWidthSizable
			
			textView.textContainer?.containerSize = NSSize(width: self.bounds.width, height: CGFloat(FLT_MAX))
			textView.textContainer?.widthTracksTextView = true
			
			textView.layerContentsRedrawPolicy = .beforeViewResize
			
			wrapperView.textView = textView
			
		#else
			
			self.addSubview(textView)
			textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
			textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			textView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			textView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		
		#endif
		
		textView.delegate = self
		
		textView.text = ""
		textView.font = theme.font
		
		
		textView.backgroundColor = .clear
		
		#if os(iOS)

		textView.autocapitalizationType = .none
		textView.keyboardType = .asciiCapable
		textView.autocorrectionType = .no
		textView.spellCheckingType = .no
		
		textView.keyboardAppearance = .dark
		
		
		keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 50.0))
		
		let equalsBtn = UIBarButtonItem(title: "=", style: .plain, target: self, action: #selector(test))
		
		let font = UIFont.systemFont(ofSize: 44.0)
		let attributes = [NSFontAttributeName : font]

		equalsBtn.setTitleTextAttributes(attributes, for: .normal)
		
		keyboardToolbar.items = [equalsBtn]
		
//		textView.inputAccessoryView = keyboardToolbar
		
//		equalsBtn.tintColor = .red
		
		self.clipsToBounds = true
		
		#endif

	}
	
	#if os(macOS)
	
	public override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
		
		self.backgroundColor = theme.backgroundColor

	}
	
	func didScroll(_ notification: Notification) {
		
		wrapperView.setNeedsDisplay(wrapperView.bounds)
		
	}

	#endif

	#if os(iOS)

		func test() {
			textView.insertText("=")
		}
		
	#endif


	// MARK: -
	
	#if os(iOS)

	public override var isFirstResponder: Bool {
		return textView.isFirstResponder
	}
	
	#endif

	
	public var text: String {
		get {
			#if os(macOS)
				return textView.string ?? ""
			#else
				return textView.text ?? ""
			#endif
		}
		set {
			#if os(macOS)
				textView.layer!.isOpaque = true

				textView.string = newValue
			#else
				textView.text = newValue
			#endif
		}
	}
	
	// MARK: -
	
	#if os(iOS)

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.textView.setNeedsDisplay()
	}
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		
		self.textView.setNeedsDisplay()

	}
	
	#endif

	private var theme: SyntaxColorTheme {
		return DefaultTheme()
	}
	
	func colorTextView() {
		
		guard let string = textView.text else {
			return
		}
		
		self.backgroundColor = theme.backgroundColor
		
		let lexer = Lexer(input: string)
		let tokens = lexer.tokenize()
		
		let attributedString = NSMutableAttributedString(string: string)
		
		var attributes = [String : Any]()
		
		let wholeRange = NSRange(location: 0, length: string.characters.count)
		attributedString.addAttribute(NSForegroundColorAttributeName, value: theme.color(for: .plain), range: wholeRange)
		attributedString.addAttribute(NSFontAttributeName, value: theme.font, range: wholeRange)
		
		attributes[NSForegroundColorAttributeName] = theme.color(for: .plain)
		attributes[NSFontAttributeName] = theme.font
		
		#if os(macOS)
			textView.textStorage!.setAttributes(attributes, range: wholeRange)
		#else
			textView.textStorage.setAttributes(attributes, range: wholeRange)
		#endif
		
		for token in tokens {
			
			let syntaxColorType = token.type.syntaxColorType
			
			if syntaxColorType == .plain {
				continue
			}
			
			guard let tokenRange = token.range else {
				continue
			}
			
			let color = theme.color(for: syntaxColorType)

			let range = string.nsRange(fromRange: tokenRange)
			
			//			attributedString.addAttribute(, value: color, range: range)
			
			var attr = attributes
			attr[NSForegroundColorAttributeName] = color
			
			#if os(macOS)
				textView.textStorage!.setAttributes(attr, range: range)
			#else
				textView.textStorage.setAttributes(attr, range: range)
			#endif
			
		}
		
		//		sourceTextView.typingAttributes = attributedString.attributes
		//		sourceTextView.attributedText = attributedString
		
	}
	
}

#if os(macOS)
	
	extension SyntaxTextView: NSTextViewDelegate {
		
		public func textDidChange(_ notification: Notification) {
			guard let textView = notification.object as? NSTextView else {
				return
			}

			colorTextView()

			textView.setNeedsDisplay(textView.bounds)
			
			wrapperView.setNeedsDisplay(wrapperView.bounds)
			self.delegate?.didChangeText(self)

		}
		
	}
	
#endif

#if os(iOS)

	extension SyntaxTextView: UITextViewDelegate {
		
		public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			
			return true
		}
		
		public func textViewDidChange(_ textView: UITextView) {
			
			textView.setNeedsDisplay()
			colorTextView()
			
		}
		
	}

#endif

extension String {
	
	func nsRange(fromRange range: Range<Int>) -> NSRange {
		let from = range.lowerBound
		let to = range.upperBound
		
		let fromIndex = self.index(startIndex, offsetBy: from)
		let toIndex = self.index(startIndex, offsetBy: to)
		
		let location = characters.distance(from: startIndex, to: fromIndex)
		let length = characters.distance(from: fromIndex, to: toIndex)
		
		return NSRange(location: location, length: length)
	}
	
//	func range(fromNSRange range: NSRange) -> Range<String.Index> {
//		
//		let start = self.index(self.startIndex, offsetBy: range.lowerBound)
//		let end = self.index(start, offsetBy: range.length)
//		
//		return start..<end
//	}
	
}
