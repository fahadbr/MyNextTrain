//
//  TripSummary.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

public protocol TripSummary {
	
	var departureTime: Date { get }
	var arrivalTime: Date { get }
	
	var tripTime: TimeInterval { get }
	
    var scheduleDescription: NSAttributedString { get }
    var upcomingEventDescription: String { get }
	
}

public extension TripSummary {
	
	var tripTime: TimeInterval {
		return arrivalTime - departureTime
	}
	
}
