//
//  StopPairing.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

public protocol StopPairing: CustomStringConvertible {
	
	var fromStop: Stop { get }
	var toStop: Stop { get }

    init(fromStop: Stop, toStop: Stop)

}

extension StopPairing {
	
	public var description: String {
		return "\(fromStop.name) -> \(toStop.name)"
	}
    
    public var directionId: Int {
        return fromStop.longitude > toStop.longitude ? 1 : 0
    }

    public var switched: StopPairing {
        return Self(fromStop: toStop, toStop: fromStop)
    }
	
}
