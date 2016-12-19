//
//  TransferTripSummaryDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/14/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class TransferTripSummaryDTO: TripSummary {
	
	var departureTime: TimeInterval
	var arrivalTime: TimeInterval

    var transferStopName: String
    var transferTime: Pair<TimeInterval>
    var fromRouteName: String
    var fromRouteColor: UIColor

    init(departureTime: TimeInterval,
        arrivalTime: TimeInterval,
        transferStopName: String,
        transferTime: Pair<TimeInterval>,
        fromRouteName: String,
        fromRouteColor: UIColor) {

        self.departureTime    = departureTime
        self.arrivalTime      = arrivalTime
        self.transferStopName = transferStopName
        self.transferTime     = transferTime
        self.fromRouteName    = fromRouteName
        self.fromRouteColor   = fromRouteColor
    }

	func scheduleDescription(for date: Date) -> NSAttributedString {
		let departing = departureTime
		let arriving = arrivalTime
		let smallFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
		
		let timeDiff = arriving - departing
		return AttributedStringBuilder()
			.append(text: "\(departing.timeRepresenation(from: date)) - \(arriving.timeRepresenation(from: date))")
			.append(text: " • \(timeDiff.timeRepresentation)", font: smallFont, color: UIColor.altText)
			.append(text: " • \(fromRouteName) ", font: smallFont, color: fromRouteColor)
			.append(text: " • \(transferTime.left.timeRepresenation(from: date)) - \(transferTime.right.timeRepresenation(from: date))", font:smallFont)
			.build
	}
	
	func upcomingEventDescription(for currentTime: TimeInterval) -> String {
		func description() -> String {
			switch currentTime {
			case 0 ..< departureTime:
				return "Departing in " + (departureTime - currentTime).timeRepresentation
			case departureTime ..< (arrivalTime - 1):
				return "Arriving in " + (arrivalTime - currentTime).timeRepresentation
			default:
				return "Arrived"
			}
		}
		return description() + " • Transfer at \(transferStopName)"
	}
	
}
