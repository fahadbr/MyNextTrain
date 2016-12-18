//
//  TripSummaryImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class DirectTripSummaryDTO: TripSummary {
	

    let departureTime: TimeInterval
    let arrivalTime: TimeInterval
    let routeName: String
    let routeColor: UIColor


	init(stopTimes: Pair<StopTime>, trip: Trip, route: Route) {
        self.departureTime = stopTimes.left.departureTime
        self.arrivalTime = stopTimes.right.arrivalTime
        self.routeName = route.longName
        self.routeColor = route.uiColor
	}
	
	func scheduleDescription(for date: Date) -> NSAttributedString {
		let departing = departureTime
		let arriving = arrivalTime
		let smallFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
		
		let timeDiff = arriving - departing
		return AttributedStringBuilder()
			.append(text: "\(departing.timeRepresenation(from: date)) - \(arriving.timeRepresenation(from: date))")
			.append(text: " • \(timeDiff.timeRepresentation) • ", font: smallFont, color: UIColor.altText)
			.append(text: " \(routeName) ", font: smallFont, color: routeColor)
			.build
	}
	
	func upcomingEventDescription(for currentTime: TimeInterval) -> String {
		switch currentTime {
		case 0 ..< departureTime:
			return "Departing in " + (departureTime - currentTime).timeRepresentation
		case departureTime ..< (arrivalTime - 1):
			return "Arriving in " + (arrivalTime - currentTime).timeRepresentation
		default:
			return "Arrived"
		}
	}
	
}
