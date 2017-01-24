//
//  SyntaxTheme.swift
//  JungleKit
//
//  Created by Louis D'hauwe on 24/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import Lioness

protocol SyntaxColorTheme {
	
	var font: UIFont { get }
	
	var backgroundColor: UIColor { get }
	
	func color(for syntaxColorType: SyntaxColorType) -> UIColor
}

class DefaultTheme: SyntaxColorTheme {
	
	let font = UIFont(name: "Menlo", size: 19)!
	
	let backgroundColor: UIColor = .white
	
	func color(for syntaxColorType: SyntaxColorType) -> UIColor {
		
		switch syntaxColorType {
		case .plain:
			return .black
		case .number:
			return .black
		case .identifier:
			return .blue
		case .keyword:
			return .blue
		case .comment:
			return UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
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
		
		return .plain
	}
	
}
	
