//
//  StopPairing.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol StopPairing: CustomStringConvertible {
	
	var fromStop: Stop { get }
	var toStop: Stop { get }
	
}

extension StopPairing {
	
	var description: String {
		return "\(fromStop.name) -> \(toStop.name)"
	}
    
    var directionId: Int {
        return fromStop.longitude > toStop.longitude ? 1 : 0
    }
	
}
