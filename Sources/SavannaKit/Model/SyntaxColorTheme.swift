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
	
	func color(for syntaxColorType: SyntaxColorType) -> Color
}

public struct DefaultTheme: SyntaxColorTheme {
	
	private static var lineNumbersColor: Color {
		return Color(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
	}
	
	public let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: Font(name: "Menlo", size: 16)!, textColor: lineNumbersColor, backgroundColor: Color(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0))

	public let font = Font(name: "Menlo", size: 15)!
	
	public let backgroundColor = Color(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
	
	public func color(for syntaxColorType: SyntaxColorType) -> Color {
		return .white
	}
}

public struct SyntaxColorType {
    public let identifier: String
    public let isEditorPlaceholder: Bool
    
    public init(identifier: String, isEditorPlaceholder: Bool = false) {
        self.identifier = identifier
        self.isEditorPlaceholder = isEditorPlaceholder
    }
}

