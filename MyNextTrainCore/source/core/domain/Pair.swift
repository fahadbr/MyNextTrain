//
//  FromToPair.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/14/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

class Pair<T>: Hashable {
	
	let left: T
	let right: T
	
	init(_ from: T, _ to: T) {
		self.left = from
		self.right = to
	}
	
	func with(right newRight: T) -> Pair<T> {
		return Pair(left,  right)
	}
	
	func with(left newLeft: T) -> Pair<T> {
		return Pair(newLeft,  right)
	}

    var hashValue: Int {
        return "\(left)\(right)".hashValue
    }

    static func ==<T>(lhs: Pair<T>, rhs: Pair<T>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
