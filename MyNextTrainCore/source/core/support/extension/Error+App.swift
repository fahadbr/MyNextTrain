//
//  ErrorExtension.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/30/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

public extension Error {
	
	var description: String {
		return (self as? CustomStringConvertible)?.description ?? "\(self)"
	}
	
}




