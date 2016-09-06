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
    
    static let instance = RealmQueryService()
    
    func tripSummaries(from startingStop: Stop, to destinationStop: Stop, forDate date: Date) -> [TripSummary] {
        
		do {
			let realm = try Realm()
			Logger.debug("searching using stops from \(startingStop.name) to \(destinationStop.name) for date \(date)")
			
            func stopTimes(forStop stop: Stop) -> [String : StopTimeImpl] {
                return realm.allObjects(ofType: StopTimeImpl.self).filter(using: "stopId == \(stop.id)").dictionary { $0.tripId }
            }
            
			let startingStopTimes = stopTimes(forStop: startingStop)
			let destinationStopTimes = stopTimes(forStop: destinationStop)
            
            let commonTripIds = Set<String>(startingStopTimes.keys).intersection(destinationStopTimes.keys)
			
			Logger.debug("tripIds to query \(commonTripIds)")
            
            let calendarDates = realm.allObjects(ofType: CalendarDateImpl.self).filter(using: "date == %@", date)
            let serviceIds: [String] = calendarDates.map { $0.serviceId }
            
            let trips = realm.allObjects(ofType: TripImpl.self).filter(using: "id IN %@ AND serviceId IN %@", commonTripIds, serviceIds)
			
			Logger.debug("found \(trips.count) trips")
			
            var summaries = [TripSummary]()
            for trip in trips {
                let startingStopTime = startingStopTimes[trip.id]!
                let destinationStopTime = destinationStopTimes[trip.id]!
                if startingStopTime.stopSequence <= destinationStopTime.stopSequence {
                    let summary = TripSummaryImpl()
                    summary._startingStop = startingStopTime
                    summary._destinationStop = destinationStopTime
                    summary._trip = trip
                    summaries.append(summary)
                }
            }
            Logger.debug("found \(summaries.count) summaries")
            return summaries.sorted { $0.0.startingStop.departureTime < $0.1.startingStop.departureTime }
			
		} catch let error {
			Logger.error("error with finding trips", error: error)
		}
		
		return []
	}
    
	
}
