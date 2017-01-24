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

public class SyntaxTextView: UIView, UITextViewDelegate {

	private let textView: UITextView
	
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

		textView = UITextView(frame: .zero)

		switch initMethod {
		case let .coder(coder): super.init(coder: coder)
		case let .frame(frame): super.init(frame: frame)
		}
		
		setup()
	}
	
	private var keyboardToolbar: UIToolbar!
	
	private func setup() {
		
		textView.translatesAutoresizingMaskIntoConstraints = false
		
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
		
		keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 50.0))
		
		let equalsBtn = UIBarButtonItem(title: "=", style: .plain, target: self, action: #selector(test))
		
		let font = UIFont.systemFont(ofSize: 44.0)
		let attributes = [NSFontAttributeName : font]

		equalsBtn.setTitleTextAttributes(attributes, for: .normal)
		
		keyboardToolbar.items = [equalsBtn]
		
//		textView.inputAccessoryView = keyboardToolbar
		
//		equalsBtn.tintColor = .red
		
	}
	
	func test() {
		textView.insertText("=")
	}

	// MARK: -
	
	public var text: String {
		return textView.text ?? ""
	}
	
	// MARK: -
	
	public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
		return true
	}
	
	public func textViewDidChange(_ textView: UITextView) {
		
		colorTextView()
		
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
			
			let color = theme.color(for: syntaxColorType)
			let range = string.nsRange(fromRange: token.range)
			
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
	func nsRange(fromRange range: Range<Index>) -> NSRange {
		let from = range.lowerBound
		let to = range.upperBound
		
		let location = characters.distance(from: startIndex, to: from)
		let length = characters.distance(from: from, to: to)
		
		return NSRange(location: location, length: length)
	}
}
