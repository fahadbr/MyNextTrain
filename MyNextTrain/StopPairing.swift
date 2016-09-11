//
//  StopPairing.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol StopPairing: CustomStringConvertible {
	
	var startingStop: Stop! { get }
	var destinationStop: Stop! { get }
	
}

extension StopPairing {
	
	var description: String {
		return "\(startingStop.name) -> \(destinationStop.name)"
	}
    
    var directionId: Int {
        return startingStop.longitude > destinationStop.longitude ? 1 : 0
    }
	
}
