//
//  FromToPair.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/14/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

final class FromToPair<T> {
	
	let from: T
	let to: T
	
	init(from: T, to: T) {
		self.from = from
		self.to = to
	}
	
	func to(_ newTo: T) -> FromToPair<T> {
		return FromToPair(from: from, to: newTo)
	}
	
	func from(_ newFrom: T) -> FromToPair<T> {
		return FromToPair(from: newFrom, to: to)
	}
	
}
