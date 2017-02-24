//
//  ID.swift
//  My
//
//  Created by Daniel Tartaglia on 2/24/17.
//  Copyright © 2017 Haneke Design. All rights reserved.
//

import Foundation


struct ID: Hashable {
	var hashValue: Int {
		return rawValue.hash
	}

	static func ==(lhs: ID, rhs: ID) -> Bool {
		return lhs.rawValue.isEqual(rhs.rawValue)
	}
	
	private let rawValue = NSUUID()
}

