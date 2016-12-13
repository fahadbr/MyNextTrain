//
//  DictionaryExtension.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/14/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

extension Dictionary {
	
	mutating func get(key: Key, or compute: ()->Value) -> Value {
		if let v = self[key] {
			return v
		}
		let d = compute()
		self[key] = d
		return d
	}
	
}
