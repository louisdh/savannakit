//
//  SyntaxTheme.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public struct LineNumbersStyle {
	
	public let font: Font
	public let textColor: Color
	public let backgroundColor: Color
	
	public init(font: Font, textColor: Color, backgroundColor: Color) {
		self.font = font
		self.textColor = textColor
		self.backgroundColor = backgroundColor
	}

}

public protocol SyntaxColorTheme {
	
	/// Nil hides line numbers.
	var lineNumbersStyle: LineNumbersStyle? { get }
	
	var font: Font { get }
	
	var backgroundColor: Color { get }

	func globalAttributes() -> [NSAttributedStringKey: Any]

	func attributes(for token: Token) -> [NSAttributedStringKey: Any]
}
