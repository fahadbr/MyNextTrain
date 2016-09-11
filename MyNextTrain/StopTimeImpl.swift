//
//  StopTimeImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/23/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift


class StopTimeImpl: Object, StopTime, GTFSFileEntry {
	
	dynamic var tripId: String = ""
	dynamic var arrivalTime: TimeInterval = 0
	dynamic var departureTime: TimeInterval = 0
	dynamic var stopId: Int = 0
	dynamic var stopSequence: Int = 0
	
	func apply(row: GTFSFileRow) {
		row.bind(column: "trip_id", to: &tripId)
		row.bind(column: "arrival_time", to: &arrivalTime)
		row.bind(column: "departure_time", to: &departureTime)
		row.bind(column: "stop_id", to: &stopId)
		row.bind(column: "stop_sequence", to: &stopSequence)
	}
    
    override class func indexedProperties() -> [String] {
        return ["stop_id"]
    }
	
}
