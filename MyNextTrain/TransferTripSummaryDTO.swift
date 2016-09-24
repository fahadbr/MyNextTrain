//
//  TransferTripSummaryDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/14/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class TransferTripSummaryDTO: TripSummary {
	
	var departureTime: TimeInterval {
		return stopTimes.from.departureTime
	}
	
	var arrivalTime: TimeInterval {
		return stopTimes.to.arrivalTime
	}

	var stopTimes: FromToPair<StopTime>!
	var trips: FromToPair<Trip>!
	var routes: FromToPair<Route>!
//	var transferTime: Double = 0
	var transferStop: Stop!
	var transferStopTime: StopTime!
	
	func scheduleDescription(for date: Date) -> NSAttributedString {
		let departing = departureTime
		let arriving = arrivalTime
		let smallFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
		
		let timeDiff = arriving - departing
		return AttributedStringBuilder()
			.append(text: "\(departing.timeRepresenation(from: date)) - \(arriving.timeRepresenation(from: date))")
			.append(text: " • \(timeDiff.timeRepresentation)", font: smallFont, color: UIColor.altText)
			.append(text: " • \(routes.from.longName) ", font: smallFont, color: routes.from.uiColor)
			.append(text: " • \(transferStopTime.arrivalTime.timeRepresenation(from: date)) - \(transferStopTime.departureTime.timeRepresenation(from: date))", font:smallFont)
			.build
	}
	
	func upcomingEventDescription(for currentTime: TimeInterval) -> String {
		func description() -> String {
			switch currentTime {
			case 0 ..< stopTimes.from.departureTime:
				return "Departing in " + (stopTimes.from.departureTime - currentTime).timeRepresentation
			case stopTimes.from.departureTime ..< (stopTimes.to.arrivalTime - 1):
				return "Arriving in " + (stopTimes.to.arrivalTime - currentTime).timeRepresentation
			default:
				return "Arrived"
			}
		}
		return description() + " • Transfer at \(transferStop.name)"
	}
	
}
