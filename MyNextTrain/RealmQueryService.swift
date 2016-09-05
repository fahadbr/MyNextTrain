//
//  RealmQueryService.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/4/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift

class RealmQueryService: QueryService {
	
	func trips(from startingStop: Stop, to destinationStop: Stop) -> [Trip] {
		
		do {
			let realm = try Realm()
			Logger.debug("searching using stops from \(startingStop.name) to \(destinationStop.name)")
			
			func transformToTripIds(_ stopTimes: Results<StopTimeImpl>) -> String {
				return "{\(stopTimes.map { "'\($0.tripId)'" }.joined(separator: ",") )}"
			}
			
			let startingStopTimes = realm.allObjects(ofType: StopTimeImpl.self).filter(using: "stopId = \(startingStop.id)")
			let startingStopTripIds = transformToTripIds(startingStopTimes)
			
			let destinationStopTimes = realm.allObjects(ofType: StopTimeImpl.self)
				.filter(using: "stopId = \(destinationStop.id) AND tripId in \(startingStopTripIds)")
			
			let tripIds = transformToTripIds(destinationStopTimes)
			
			Logger.debug("tripIds returned \(tripIds)")
			
			let trips = realm.allObjects(ofType: TripImpl.self).filter(using: "id in \(tripIds)")
			
			Logger.debug("found \(trips.count) trips")
			
			return Array<TripImpl>(trips)
			
		} catch let error {
			Logger.error("error with finding trips", error: error)
		}
		
		return []
	}
	
}
