//
//  SyntaxTextView.swift
//  Lioness Jungle
//
//  Created by Louis D'hauwe on 23/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import UIKit
import Lioness

private enum InitMethod {
	case coder(NSCoder)
	case frame(CGRect)
}

struct Paragraph {
	
	let rect: CGRect
	let number: Int
	
	var string: String {
		return "\(number)"
	}
	
	func attributedString(for theme: SyntaxColorTheme) -> NSAttributedString {
		
		let attr = NSMutableAttributedString(string: string)
		let range = NSMakeRange(0, attr.length)
		
		let attributes = [
			NSFontAttributeName: theme.lineNumbersStyle.font,
			NSForegroundColorAttributeName : theme.lineNumbersStyle.textColor
		]
		
		attr.addAttributes(attributes, range: range)
		
		return attr
	}
	
	func drawSize(for theme: SyntaxColorTheme) -> CGSize {
		return attributedString(for: theme).size()
	}
	
}

public class FooTextView: UITextView {
	
	private var theme: SyntaxColorTheme {
		return DefaultTheme()
	}
	
	func paragraphRectForRange(range: Range<String.Index>) -> CGRect {
		
		let range = self.textStorage.string.paragraphRange(for: range)
		
		let start = text.distance(from: text.startIndex, to: range.lowerBound)
		let length = text.distance(from: range.lowerBound, to: range.upperBound)
		
		var nsRange = NSMakeRange(start, length)
		
		nsRange = self.layoutManager.glyphRange(forCharacterRange: nsRange, actualCharacterRange: nil)
		
		var sectionRect = layoutManager.boundingRect(forGlyphRange: nsRange, in: self.textContainer)
//		sectionRect.origin.x += textContainerInset.left
		sectionRect.origin.x = 0
		
		return sectionRect
	}
	
	override public func draw(_ rect: CGRect) {
		
//		UIColor.red.setFill()
//
//		let gutterRect = CGRect(x: 0, y: 0, width: 20, height: rect.height)
//		let path = UIBezierPath(rect: gutterRect)
//		path.fill()
		
		let range = self.text.startIndex..<self.text.endIndex
		
		var paragraphs = [Paragraph]()
		var i = 0
		
		let selectedRange = self.selectedRange
		
		let stringRange = self.text.range(fromNSRange: selectedRange)
		
		
//		print(self.text.substring(with: stringRange))
		
		self.text.enumerateSubstrings(in: range, options: [.byParagraphs]) { (paragraphContent, paragraphRange, enclosingRange, stop) in
			
			i += 1
			
			let rect = self.paragraphRectForRange(range: paragraphRange)
//			print(rect)
			
			let paragraph = Paragraph(rect: rect, number: i)
			paragraphs.append(paragraph)
			
		}
		
		if self.text.isEmpty || self.text.hasSuffix("\n") {
			
			let rect: CGRect
			
			let gutterWidth = textContainerInset.left
			let lineHeight: CGFloat = 22
			
			if let last = paragraphs.last {
				
				rect = CGRect(x: 0, y: last.rect.origin.y + lineHeight, width: gutterWidth, height: lineHeight)
				
			} else {
				
				rect = CGRect(x: 0, y: 0, width: gutterWidth, height: lineHeight)
				
			}
			
			i += 1
			let endParagraph = Paragraph(rect: rect, number: i)
			paragraphs.append(endParagraph)
			
		}
		
//		print(paragraphs.map { $0.rect })
		
		let sizes = paragraphs.map { $0.attributedString(for: theme).size() }
		
		for paragraph in paragraphs {
			
			guard paragraph.rect.intersects(rect) else {
				continue
			}
			
			let attr = paragraph.attributedString(for: theme)
			
			attr.draw(in: paragraph.rect)
			
		}
		
		super.draw(rect)
	}
	
}

public class SyntaxTextView: UIView, UITextViewDelegate {

	private let textView: FooTextView
	
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
	
	override convenience init(frame: CGRect) {
		self.init(.frame(frame))!
	}
	
	public required convenience init?(coder aDecoder: NSCoder) {
		self.init(.coder(aDecoder))
	}
	
	private init?(_ initMethod: InitMethod) {

		textView = FooTextView(frame: .zero)

		switch initMethod {
		case let .coder(coder): super.init(coder: coder)
		case let .frame(frame): super.init(frame: frame)
		}
		
		setup()
	}
	
	private var keyboardToolbar: UIToolbar!
	
	private func setup() {
		
		textView.translatesAutoresizingMaskIntoConstraints = false
		
		textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
		
		self.addSubview(textView)
		textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		textView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		textView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		
		textView.delegate = self
		
		textView.text = ""
		textView.font = theme.font
		self.backgroundColor = theme.backgroundColor
		textView.backgroundColor = .clear
		
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
	}
	
	func test() {
		textView.insertText("=")
	}

	// MARK: -
	
	public override var isFirstResponder: Bool {
		return textView.isFirstResponder
	}
	
	public var text: String {
		return textView.text ?? ""
	}
	
	// MARK: -
	
	public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
		return true
	}
	
	public func textViewDidChange(_ textView: UITextView) {
		
		self.textView.setNeedsDisplay()
		colorTextView()
		
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.textView.setNeedsDisplay()
	}
	
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
		
		textView.textStorage.setAttributes(attributes, range: wholeRange)
		
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
			
			textView.textStorage.setAttributes(attr, range: range)
			
		}
		
		//		sourceTextView.typingAttributes = attributedString.attributes
		//		sourceTextView.attributedText = attributedString
		
	}
	
}

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
	
	func range(fromNSRange range: NSRange) -> Range<String.Index> {
		
		let start = self.index(self.startIndex, offsetBy: range.lowerBound)
		let end = self.index(start, offsetBy: range.length)
		
		return start..<end
	}
	
}
