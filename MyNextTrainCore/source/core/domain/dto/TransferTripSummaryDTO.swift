//
//  TransferTripSummaryDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/14/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class TransferTripSummaryDTO: TripSummary {
	
	var departureTime: Date
	var arrivalTime: Date

    var transferStopName: String
    var transferTime: Pair<Date>
    var fromRouteName: String
    var fromRouteColor: UIColor

    private(set) lazy var scheduleDescription: NSAttributedString = self._scheduleDescription()

    init(departureTime: Date,
         arrivalTime: Date,
         transferStopName: String,
         transferTime: Pair<Date>,
         fromRouteName: String,
         fromRouteColor: UIColor) {

        self.departureTime    = departureTime
        self.arrivalTime      = arrivalTime
        self.transferStopName = transferStopName
        self.transferTime     = transferTime
        self.fromRouteName    = fromRouteName
        self.fromRouteColor   = fromRouteColor
    }

    private func _scheduleDescription() -> NSAttributedString {
        let departing = departureTime
        let arriving = arrivalTime
        let smallFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)

        let timeDiff = arriving - departing
        return AttributedStringBuilder()
            .append(text: "\(departing.timeRepresentation) - \(arriving.timeRepresentation)")
            .append(text: " • \(timeDiff.timeRepresentation)", font: smallFont, color: UIColor.altText)
            .append(text: " • \(fromRouteName) ", font: smallFont, color: fromRouteColor)
            .append(text: " • \(transferTime.left.timeRepresentation) - \(transferTime.right.timeRepresentation)", font:smallFont)
            .build
    }
	
    var upcomingEventDescription: String {
        let currentTime = Date()
		func description() -> String {
			switch currentTime {
			case Date.distantPast ..< departureTime:
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
