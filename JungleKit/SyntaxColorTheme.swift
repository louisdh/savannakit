//
//  SyntaxTheme.swift
//  JungleKit
//
//  Created by Louis D'hauwe on 24/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import Lioness

struct LineNumbersStyle {
	
	let font: UIFont
	let textColor: UIColor
	
}

protocol SyntaxColorTheme {
	
	var lineNumbersStyle: LineNumbersStyle { get }
	
	var font: UIFont { get }
	
	var backgroundColor: UIColor { get }
	
	func color(for syntaxColorType: SyntaxColorType) -> UIColor
}

struct DefaultTheme: SyntaxColorTheme {
	
	private static var lineNumbersColor: UIColor {
		return UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
	}
	
	let lineNumbersStyle = LineNumbersStyle(font: UIFont(name: "Menlo", size: 19)!, textColor: lineNumbersColor)
	
	let font = UIFont(name: "Menlo", size: 19)!
	
	let backgroundColor: UIColor = UIColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
	
	func color(for syntaxColorType: SyntaxColorType) -> UIColor {
		
		switch syntaxColorType {
		case .plain:
			return .white
		case .number:
			return UIColor(red: 116/255, green: 109/255, blue: 176/255, alpha: 1.0)
		case .identifier:
			return UIColor(red: 20/255, green: 156/255, blue: 146/255, alpha: 1.0)
		case .keyword:
			return UIColor(red: 215/255, green: 0, blue: 143/255, alpha: 1.0)
		case .comment:
			return UIColor(red: 69.0/255.0, green: 187.0/255.0, blue: 62.0/255.0, alpha: 1.0)
		}
		
	}
	
}

enum SyntaxColorType {
	case plain
	case number
	case identifier
	case keyword
	case comment
}

extension TokenType {
	
	var syntaxColorType: SyntaxColorType {
		
		if case .do = self {
			return .keyword
		}
		
		if case .function = self {
			return .keyword
		}
		
		if case .while = self {
			return .keyword
		}
		
		if case .if = self {
			return .keyword
		}
		
		if case .else = self {
			return .keyword
		}
		
		if case .times = self {
			return .keyword
		}
		
		if case .return = self {
			return .keyword
		}
		
		if case .returns = self {
			return .keyword
		}
		
		if case .identifier(_) = self {
			return .identifier
		}
		
		if case .comment = self {
			return .comment
		}
		
		if case .number = self {
			return .number
		}
		
		return .plain
	}
	
}
