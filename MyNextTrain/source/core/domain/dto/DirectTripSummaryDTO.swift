//
//  TripSummaryImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class DirectTripSummaryDTO: TripSummary {
	
	let stopTimes: FromToPair<StopTime>
	let trip: Trip
	let route: Route
	
	var departureTime: TimeInterval {
		return stopTimes.from.departureTime
	}
	
	var arrivalTime: TimeInterval {
		return stopTimes.to.arrivalTime
	}

	init(stopTimes: FromToPair<StopTime>, trip: Trip, route: Route) {
		self.stopTimes = stopTimes
		self.trip = trip
		self.route = route
	}
	
	func scheduleDescription(for date: Date) -> NSAttributedString {
		let departing = stopTimes.from.departureTime
		let arriving = stopTimes.to.arrivalTime
		let smallFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
		
		let timeDiff = arriving - departing
		return AttributedStringBuilder()
			.append(text: "\(departing.timeRepresenation(from: date)) - \(arriving.timeRepresenation(from: date))")
			.append(text: " • \(timeDiff.timeRepresentation) • ", font: smallFont, color: UIColor.altText)
			.append(text: " \(route.longName) ", font: smallFont, color: route.uiColor)
			.build
	}
	
	func upcomingEventDescription(for currentTime: TimeInterval) -> String {
		switch currentTime {
		case 0 ..< stopTimes.from.departureTime:
			return "Departing in " + (stopTimes.from.departureTime - currentTime).timeRepresentation
		case stopTimes.from.departureTime ..< (stopTimes.to.arrivalTime - 1):
			return "Arriving in " + (stopTimes.to.arrivalTime - currentTime).timeRepresentation
		default:
			return "Arrived"
		}
	}
	
}
