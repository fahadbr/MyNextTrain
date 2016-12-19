//
//  TripSummary.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

protocol TripSummary {
	
	var departureTime: TimeInterval { get }
	var arrivalTime: TimeInterval { get }
	
	var tripTime: TimeInterval { get }
	
	func scheduleDescription(for date: Date) -> NSAttributedString
	func upcomingEventDescription(for currentTime: TimeInterval) -> String
	
}

extension TripSummary {
	
	var tripTime: TimeInterval {
		return arrivalTime - departureTime
	}
	
}
