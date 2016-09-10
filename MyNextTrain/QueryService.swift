//
//  QueryService.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/21/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

fileprivate let formatter: DateFormatter = {
    $0.dateFormat = "ddMMyy"
    return $0
}(DateFormatter())

protocol QueryService {
	
	var favoritePairings: [StopPairing] { get }
	var allStops: [Stop] { get }
	
	func tripSummaries(for pairing: StopPairing, on date: Date) -> [TripSummary]
	func nextTripSummary(forPairing pairing: StopPairing) -> TripSummary?
}

extension QueryService {
    
    //returns the date with no time component
    var currentDate: Date {
        guard let dateNoTime = formatter.date(from: formatter.string(from: Date())) else {
//		guard let dateNoTime = formatter.date(from: "020916") else {
            Logger.error("couldn't truncate time from current date object")
            return Date()
        }
        return dateNoTime
    }
    
}
