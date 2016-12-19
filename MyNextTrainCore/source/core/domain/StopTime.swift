//
//  StopTime.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol StopTime {
	
    var tripId: String { get }
	var arrivalTime: TimeInterval { get }
	var departureTime: TimeInterval { get }
    var stopId: Int { get }
    var stopSequence: Int { get }
	
}
