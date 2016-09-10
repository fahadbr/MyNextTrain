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
	
	private typealias This = RealmQueryService
	
	var favoritePairings: [StopPairing] {
		do {
			let realm = try Realm()
			let stopPairings: [StopPairing] = realm.allObjects(ofType: StopPairingImpl.self)
				.map( {$0 as StopPairing })
			
			return stopPairings
		} catch let e {
			Logger.error("error with fetching all stopPairings", error: e)
		}
		return []
	}
	
	var allStops: [Stop] {
		do {
			let realm = try Realm()
			let stops: [Stop] = realm.allObjects(ofType: StopImpl.self)
				.sorted(onProperty: "name")
				.map( {$0 as Stop })
			
			return stops
		} catch let e {
			Logger.error("error with fetching all stops", error: e)
		}
		return []
	}
	
	
	func tripSummaries(for pairing: StopPairing, on date: Date) -> [TripSummary] {
		guard let startingStop = pairing.startingStop, let destinationStop = pairing.destinationStop else {
				Logger.error("one of startingStop or destinationStop was nil in pairing")
				return []
		}
		
		do {
			let realm = try Realm()
			Logger.debug("searching using stops from \(startingStop.name) to \(destinationStop.name) for date \(date)")
			
            func stopTimes(forStop stop: Stop) -> [String : StopTimeImpl] {
                return realm.allObjects(ofType: StopTimeImpl.self).filter(using: "stopId == \(stop.id)").dictionary { $0.tripId }
            }
            
			let startingStopTimes = stopTimes(forStop: startingStop)
			let destinationStopTimes = stopTimes(forStop: destinationStop)
            
            let commonTripIds = Set<String>(startingStopTimes.keys).intersection(destinationStopTimes.keys)
			
			let trips = findTrips(with: commonTripIds, on: date, realm: realm)
			
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
	
	func nextTripSummary(forPairing pairing: StopPairing) -> TripSummary? {
		guard let startingStop = pairing.startingStop, let destinationStop = pairing.destinationStop else {
			Logger.error("one of startingStop or destinationStop was nil in pairing")
			return nil
		}
		
		do {
			let realm = try Realm()
			Logger.debug("searching for next trip from \(startingStop.name) to \(destinationStop.name)")
			
			let date = currentDate
			let currentTimeInterval = Date().timeIntervalSince(date)
			
			let startingStopTimes = realm.allObjects(ofType: StopTimeImpl.self)
				.filter(using: "stopId == %@ AND departureTime >= %@", startingStop.id, currentTimeInterval)
				.sorted(onProperty: "departureTime")
			
			let destinationStopTimes = realm.allObjects(ofType: StopTimeImpl.self)
				.filter(using: "stopId == %@ AND arrivalTime >= %@", destinationStop.id, currentTimeInterval)
				.sorted(onProperty: "arrivalTime")
			
			
			let commonTripIds = Set<String>(startingStopTimes.map { $0.tripId })
				.intersection(Set<String>(destinationStopTimes.map { $0.tripId } ))
			
			let trips = findTrips(with: commonTripIds, on: date, realm: realm)
			
			let resultTripIds: [String] = trips.map { $0.id }
			
			guard let startingStopTime =  startingStopTimes.filter(using: "tripId IN %@", resultTripIds).first else {
				Logger.debug("no starting stop time for pairing \(pairing.description)")
				return nil
			}
			
			guard let destinationStopTime = destinationStopTimes.filter(using: "stopId == %@ AND tripId == %@ AND stopSequence > %@",
				        destinationStop.id, startingStopTime.tripId, startingStopTime.stopSequence).first else {
				Logger.debug("no destination stop time found for pairing \(pairing.description)")
				return nil
			}
			
			guard let trip = trips.filter(using: "id == %@", startingStopTime.tripId).first else {
				Logger.error("why cant i find a trip what \(pairing.description)")
				return nil
			}
			
			let summary = TripSummaryImpl()
			summary._startingStop = startingStopTime
			summary._destinationStop = destinationStopTime
			summary._trip = trip

			return summary
			
		} catch let error {
			Logger.error("error with finding trips", error: error)
		}
		
		return nil
	}
	
	private func findTrips(with tripIds: Set<String>, on date: Date, realm: Realm) -> Results<TripImpl> {
		Logger.debug("tripIds to query \(tripIds)")
		
		let calendarDates = realm.allObjects(ofType: CalendarDateImpl.self).filter(using: "date == %@", date)
		let serviceIds: [String] = calendarDates.map { $0.serviceId }
		
		let trips = realm.allObjects(ofType: TripImpl.self).filter(using: "id IN %@ AND serviceId IN %@", tripIds, serviceIds)
		
		Logger.debug("found \(trips.count) trips")
		return trips
	}
	
	
}
