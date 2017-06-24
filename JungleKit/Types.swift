//
//  Types.swift
//  JungleKit
//
//  Created by Louis D'hauwe on 24/06/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
	import AppKit
	public typealias View = NSView
	typealias TextView = NSTextView
	typealias Font = NSFont
	typealias Color = NSColor
#else
	import UIKit
	public typealias View = UIView
	typealias TextView = UITextView
	typealias Font = UIFont
	typealias Color = UIColor
#endif
