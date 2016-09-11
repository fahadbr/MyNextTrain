//
//  TripSummary.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

protocol TripSummary {
    
    var startingStop: StopTime { get }
    var destinationStop: StopTime { get }
    var trip: Trip { get }
    var route: Route { get }

}

extension TripSummary {
	
	func scheduleDescription(for date: Date) -> NSAttributedString {
		let departing = startingStop.departureTime
		let arriving = destinationStop.arrivalTime
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
        case 0 ..< startingStop.departureTime:
            return "Departing in " + (startingStop.departureTime - currentTime).timeRepresentation
        case startingStop.departureTime ..< (destinationStop.arrivalTime - 1):
            return "Arriving in " + (destinationStop.arrivalTime - currentTime).timeRepresentation
        default:
            return "Arrived"
        }
    }
	
}
