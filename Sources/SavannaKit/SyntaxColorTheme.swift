//
//  SyntaxTheme.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import Lioness

struct LineNumbersStyle {
	
	let font: Font
	let textColor: Color
	
}

protocol SyntaxColorTheme {
	
	var lineNumbersStyle: LineNumbersStyle { get }
	
	var font: Font { get }
	
	var backgroundColor: Color { get }
	
	func color(for syntaxColorType: SyntaxColorType) -> Color
}

struct DefaultTheme: SyntaxColorTheme {
	
	private static var lineNumbersColor: Color {
		return Color(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
	}
	
	let lineNumbersStyle = LineNumbersStyle(font: Font(name: "Menlo", size: 16)!, textColor: lineNumbersColor)
	
	let font = Font(name: "Menlo", size: 19)!
	
	let backgroundColor: Color = Color(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
	
	func color(for syntaxColorType: SyntaxColorType) -> Color {
		
		switch syntaxColorType {
		case .plain:
			return .white
		case .number:
			return Color(red: 116/255, green: 109/255, blue: 176/255, alpha: 1.0)
		case .identifier:
			return Color(red: 20/255, green: 156/255, blue: 146/255, alpha: 1.0)
		case .keyword:
			return Color(red: 215/255, green: 0, blue: 143/255, alpha: 1.0)
		case .comment:
			return Color(red: 69.0/255.0, green: 187.0/255.0, blue: 62.0/255.0, alpha: 1.0)
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
		
		switch self {
		case .booleanAnd, .booleanNot, .booleanOr:
			return .plain
		
		case .shortHandAdd, .shortHandDiv, .shortHandMul, .shortHandPow, .shortHandSub:
			return .plain
	
		case .equals, .notEqual, .dot, .ignoreableToken, .parensOpen, .parensClose, .curlyOpen, .curlyClose, .comma:
			return .plain
			
		case .comparatorEqual, .comparatorLessThan, .comparatorGreaterThan, .comparatorLessThanEqual, .comparatorGreaterThanEqual:
			return .plain
			
		case .other:
			return .plain
			
		case .break, .continue, .function, .if, .else, .while, .for, .do, .times, .return, .returns, .repeat, .true, .false, .struct:
			return .keyword
			
		case .comment:
			return .comment
	
		case .number:
			return .number
			
		case .identifier:
			return .identifier

		}
		
	}
	
}
