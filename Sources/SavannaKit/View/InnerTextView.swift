//
//  InnerTextView.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

class InnerTextView: TextView {
	
	lazy var theme: SyntaxColorTheme = {
		return DefaultTheme()
	}()
	
	var cachedParagraphs: [Paragraph]?
	
	func invalidateCachedParagraphs() {
		cachedParagraphs = nil
	}
	
	func updateGutterWidth(for numberOfCharacters: Int) {
		
		let leftInset: CGFloat = 4.0
		let rightInset: CGFloat = 4.0
		
		let charWidth: CGFloat = 10.0
		
		gutterWidth = CGFloat(numberOfCharacters) * charWidth + leftInset + rightInset
		
	}
	
	#if os(iOS)
	override public func draw(_ rect: CGRect) {
	
	/*
		let string = NSMutableAttributedString(attributedString: self.attributedText)

		let framesetter = CTFramesetterCreateWithAttributedString((string as CFAttributedString))
		let mutablePath = CGMutablePath()
		mutablePath.addRect(CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), transform: .identity)
		
		let totalFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), mutablePath, nil)
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		
		UIGraphicsPushContext(context)
		
		context.textMatrix = .identity
		context.translateBy(x: 0, y: bounds.size.height)
		context.scaleBy(x: 1.0, y: -1.0)
		
		let lines = CTFrameGetLines(totalFrame) as? [CTLine] ?? []
		let lineCount = CFIndex(lines.count)
		var origins = [CGPoint](repeating: CGPoint.zero, count: lineCount)
		CTFrameGetLineOrigins(totalFrame, CFRangeMake(0, 0), &origins)
		
		for index in 0..<lineCount {
			
			let line = lines[index]
			let glyphRuns = CTLineGetGlyphRuns(line) as? [CTRun] ?? []
			let glyphCount = CFArrayGetCount(glyphRuns as CFArray)
			
			for i in 0..<glyphCount {
	
				let run = glyphRuns[i]
				var attributes = CTRunGetAttributes(run) as? [AnyHashable: Any]
	
				if attributes?["HighlightText"] != nil {
					var runBounds = CGRect.zero
					var ascent: CGFloat = 0.0
					var descent: CGFloat = 0.0
					runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil))
					runBounds.size.height = ascent + descent
					runBounds.origin.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
					runBounds.origin.y = frame.size.height - origins[lineCount - index].y - runBounds.size.height
					
					let highlightColor = Color.yellow.cgColor
					
					context.setFillColor(highlightColor)
					context.setStrokeColor(highlightColor)
					context.strokePath()
					context.fill(runBounds)
				}
				
			}
			
		}

		CTFrameDraw(totalFrame, context)

		UIGraphicsPopContext()
		
		context.textMatrix = .identity
	
		*/
	
		
		let textView = self
		
		var paragraphs: [Paragraph]
		
		if let cached = textView.cachedParagraphs {
			
			paragraphs = cached
			
		} else {
			
			paragraphs = generateParagraphs(for: textView, flipRects: false)
			textView.cachedParagraphs = paragraphs
			
		}
		
		let components = textView.text.components(separatedBy: .newlines)
		
		let count = components.count
		
		let maxNumberOfDigits = "\(count)".count
		
		textView.updateGutterWidth(for: maxNumberOfDigits)
		
		Color.black.setFill()
		
		let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)
		let path = BezierPath(rect: gutterRect)
		path.fill()
		
		
		drawLineNumbers(paragraphs, in: self.bounds, for: self)
		
		super.draw(rect)
	}
	#endif
	
	var gutterWidth: CGFloat {
		set {
			
			#if os(macOS)
				textContainerInset = NSSize(width: newValue, height: 0)
			#else
				textContainerInset = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: 0)
			#endif
			
		}
		get {
			
			#if os(macOS)
				return textContainerInset.width
			#else
				return textContainerInset.left
			#endif
			
		}
	}
	
}
