//
//  SyntaxTextViewLayoutManager.swift
//  SavannaKit iOS
//
//  Created by Louis D'hauwe on 09/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

enum EditorPlaceholderState {
	case active
	case inactive
}

extension NSAttributedStringKey {
	
	static let editorPlaceholder = NSAttributedStringKey("editorPlaceholder")

}

class SyntaxTextViewLayoutManager: NSLayoutManager {
	
	override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
		
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		
		let range = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
		
		var placeholders = [(CGRect, EditorPlaceholderState)]()
		
		textStorage?.enumerateAttribute(.editorPlaceholder, in: range, options: [], using: { (value, range, stop) in
			
			if let state = value as? EditorPlaceholderState {
				
				// the color set above
				let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
				let container = self.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil)
				
				let rect = self.boundingRect(forGlyphRange: glyphRange, in: container ?? NSTextContainer())
				
				placeholders.append((rect, state))
				
			}
			
		})
		
		context.saveGState()
		context.translateBy(x: origin.x, y: origin.y)
		
		for (rect, state) in placeholders {
			
			// UIBezierPath with rounded
			
			let color = Color.darkGray
			color.setFill()
			
			let path = BezierPath(roundedRect: rect, cornerRadius: 8)
			path.fill()
			
		}
		
		context.restoreGState()

		super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)

	}
	
}
