//
//  TripSummaryImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class DirectTripSummaryDTO: TripSummary {
	

    let departureTime: Date
    let arrivalTime: Date
    let routeName: String
    let routeColor: UIColor

    private(set) lazy var scheduleDescription: NSAttributedString = self._scheduleDescription()

    init(departureTime: Date, arrivalTime: Date, trip: Trip, route: Route) {
        self.departureTime = departureTime
        self.arrivalTime   = arrivalTime
        self.routeName     = route.longName
        self.routeColor    = route.uiColor
    }

	
    private func _scheduleDescription() -> NSAttributedString {
        let departing = departureTime
        let arriving  = arrivalTime
        let smallFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)

        let timeDiff  = tripTime
		return AttributedStringBuilder()
			.append(text: "\(departing.timeRepresentation) - \(arriving.timeRepresentation)")
			.append(text: " • \(timeDiff.timeRepresentation) • ", font: smallFont, color: UIColor.altText)
			.append(text: " \(routeName) ", font: smallFont, color: routeColor)
			.build
	}

    var upcomingEventDescription: String {
        let currentTime = Date()
		switch currentTime {
		case Date.distantPast ..< departureTime:
			return "Departing in " + (departureTime - currentTime).timeRepresentation
		case departureTime ..< (arrivalTime - 1):
			return "Arriving in " + (arrivalTime - currentTime).timeRepresentation
		default:
			return "Arrived"
		}
	}


}
