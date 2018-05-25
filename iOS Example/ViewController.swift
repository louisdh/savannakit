//
//  ViewController.swift
//  iOS Example
//
//  Created by Louis D'hauwe on 25/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import SavannaKit

class ViewController: UIViewController {

	@IBOutlet weak var syntaxTextView: SyntaxTextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		syntaxTextView.delegate = self
		syntaxTextView.theme = MyTheme()
	}
	
}

extension ViewController: SyntaxTextViewDelegate {
	
	func didChangeText(_ syntaxTextView: SyntaxTextView) {
		
		
	}
	
	func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
		
		
	}
	
	func lexerForSource(_ source: String) -> Lexer {
		return MyLexer(source: source)
	}
	
}

class MyLexer: Lexer {
	
	let source: String
	
	init(source: String) {
		self.source = source
	}
	
	func lexerForInput(_ input: String) -> Lexer {
		return MyLexer(source: input)
	}
	
	func getSavannaTokens() -> [Token] {
		
		let words = source.split(separator: " ")
		
		var tokens = [MyToken]()
		
		var range: Range<String.Index>!
		
		for word in words {
			
			if range == nil {
				range = source.startIndex..<source.index(source.startIndex, offsetBy: word.count)
			} else {
				// Offset 1 for space
				let start = source.index(range.upperBound, offsetBy: 1)
				range = start..<source.index(start, offsetBy: word.count)
			}
			
			let type: MyTokenType
			
			if word.count > 6 {
				type = .longWord
			} else {
				type = .shortWord
			}
			
			let token = MyToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
			
			tokens.append(token)
		}
		
		return tokens
	}
	
}

enum MyTokenType {
	case longWord
	case shortWord
}

struct MyToken: Token {
	
	let type: MyTokenType
	
	let isEditorPlaceholder: Bool
	
	let isPlain: Bool
	
	let range: Range<String.Index>
	
}

class MyTheme: SyntaxColorTheme {
	
	private static var lineNumbersColor: Color {
		return Color(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
	}
	
	public let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: Font(name: "Menlo", size: 16)!, textColor: lineNumbersColor, backgroundColor: Color(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0))
	
	public let font = Font(name: "Menlo", size: 15)!
	
	public let backgroundColor = Color(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
	
	func globalAttributes() -> [NSAttributedStringKey: Any] {
		
		var attributes = [NSAttributedStringKey: Any]()

		attributes[.font] = Font(name: "Menlo", size: 15)!
		
		return attributes
	}
	
	func attributes(for token: Token) -> [NSAttributedStringKey: Any] {
		
		guard let myToken = token as? MyToken else {
			return [:]
		}
		
		var attributes = [NSAttributedStringKey: Any]()
		
		switch myToken.type {
		case .longWord:
			attributes[.foregroundColor] = UIColor.red
			
		case .shortWord:
			attributes[.foregroundColor] = UIColor.white

		}
		
		return attributes
	}
	
}
