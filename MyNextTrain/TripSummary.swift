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
	
	func scheduleDescription(for date: Date) -> NSAttributedString
	func upcomingEventDescription(for currentTime: TimeInterval) -> String
	
}

//protocol DirectTripSummary: TripSummary {
//	
//	var trip: Trip { get }
//	var route: Route { get }
//	
//}
//
//protocol TransferTripSummary: TripSummary {
//	var trips: FromToPair<Trip> { get }
//	var routes: FromToPair<Route> { get }
//	
//}



