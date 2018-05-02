//
//  SavannaKitTests.swift
//  SavannaKitTests
//
//  Created by Louis D'hauwe on 02/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import XCTest
@testable import SavannaKit

public enum TestTokenType: Equatable {
	case keyword
	case variable
	case equals
	case number
}

extension TestTokenType: TokenType {
	
	public var syntaxColorType: SyntaxColorType {
		switch self {
		case .keyword:
			return .keyword
		case .variable:
			return .identifier
		case .equals:
			return .plain
		case .number:
			return .number
		}
	}
	
}

struct TestToken: Token {
	
	var tokenType: TestTokenType
	
	var range: Range<Int>?

	var savannaTokenType: TokenType {
		return tokenType
	}
	
}

class SavannaKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testAttributedText() {
		
		let source = "var a = 10"
		
		var tokens = [TestToken]()
		tokens.append(TestToken(tokenType: .keyword, range: 0..<3))
		tokens.append(TestToken(tokenType: .variable, range: 4..<5))
		tokens.append(TestToken(tokenType: .equals, range: 6..<7))
		tokens.append(TestToken(tokenType: .number, range: 8..<10))
		
		let attrString = NSMutableAttributedString(source: source, tokens: tokens, theme: DefaultTheme())

		// TODO: test this
	}
    
}
