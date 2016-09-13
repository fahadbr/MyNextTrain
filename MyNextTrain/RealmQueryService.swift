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
	
    private lazy var routesById: [Int : RouteImpl] = self.loadRoutesById()
    private var serviceIdCache = [Date : [String]]()
    
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
    
    
	
    private func loadRoutesById() -> [Int : RouteImpl] {
        do {
            let realm = try Realm()
            let routes = realm.allObjects(ofType: RouteImpl.self)
            Logger.debug("loaded \(routes.count) routes")
            return routes.dictionary(keyExtractor: { $0.id })
        
        } catch let e {
            Logger.error("error fetching routes", error: e)
        }
        return [:]
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
            
            let fromTripIds = Set<String>(startingStopTimes.keys)
            let toTripIds = Set<String>(destinationStopTimes.keys)
            
            let commonTripIds = fromTripIds.intersection(toTripIds)
            
			let trips = findTrips(with: commonTripIds, on: date, directionId: pairing.directionId, realm: realm)
            
            let i = findTransfers(fromTripIds: fromTripIds.subtracting(toTripIds),
                                  toTripIds: toTripIds.subtracting(fromTripIds),
                                  on: date,
                                  realm: realm)
            Logger.debug("FOUND \(i.count) TRANSFERS")
			
            let summaries = trips.map { trip -> TripSummary in
                let summary = TripSummaryImpl()
                summary._startingStop = startingStopTimes[trip.id]
                summary._destinationStop = destinationStopTimes[trip.id]
                summary._trip = trip
                summary._route = self.routesById[trip.routeId]
                return summary
            }
            
            Logger.debug("found \(summaries.count) summaries")
            return summaries.sorted { $0.0.startingStop.departureTime < $0.1.startingStop.departureTime }
			
		} catch let error {
			Logger.error("error with finding trips", error: error)
		}
		
		return []
	}
	
	func nextTripSummary(forPairing pairing: StopPairing) -> (isForTomorrow: Bool, summary:TripSummary)? {
        let date = currentDate
        let currentTimeInterval = Date().timeIntervalSince(date)
        if let summary = nextTripSummary(forPairing: pairing, date: date, timeInterval: currentTimeInterval) {
            return (false, summary)
        }
        
        let nextDate = date + (3600 * 24)
        if let nextDayTripSummary = nextTripSummary(forPairing: pairing, date: nextDate, timeInterval: 0) {
            return (true, nextDayTripSummary)
        }
        
        return nil
	}
    
    private func nextTripSummary(forPairing pairing: StopPairing, date: Date, timeInterval: TimeInterval) -> TripSummary? {
        guard let startingStop = pairing.startingStop, let destinationStop = pairing.destinationStop else {
            Logger.error("one of startingStop or destinationStop was nil in pairing")
            return nil
        }
        do {
            let realm = try Realm()
            Logger.debug("searching for next trip from \(startingStop.name) to \(destinationStop.name) on \(date)")
            
            let startingStopTimes = realm.allObjects(ofType: StopTimeImpl.self)
                .filter(using: "stopId == %@ AND departureTime >= %@", startingStop.id, timeInterval)
                .sorted(onProperty: "departureTime")
            
            let destinationStopTimes = realm.allObjects(ofType: StopTimeImpl.self)
                .filter(using: "stopId == %@ AND arrivalTime >= %@", destinationStop.id, timeInterval)
                .sorted(onProperty: "arrivalTime")
            
            let commonTripIds = Set<String>(startingStopTimes.map { $0.tripId })
                .intersection(Set<String>(destinationStopTimes.map { $0.tripId } ))
            
            let trips = findTrips(with: commonTripIds, on: date, directionId: pairing.directionId, realm: realm)
            
            let resultTripIds: [String] = trips.map { $0.id }
            
            guard let startingStopTime =  startingStopTimes.filter(using: "tripId IN %@", resultTripIds).first else {
                Logger.debug("no starting stop time for pairing \(pairing.description)")
                return nil
            }
            
            guard let destinationStopTime = destinationStopTimes.filter(using: "tripId == %@ AND stopSequence > %@",
                                                                        startingStopTime.tripId, startingStopTime.stopSequence).first else {
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
            summary._route = routesById[trip.routeId]
            
            return summary
            
        } catch let error {
            Logger.error("error with finding trips", error: error)
        }
        
        return nil
    }
	
    private func findTrips(with tripIds: Set<String>, on date: Date, directionId: Int? = nil, realm: Realm) -> Results<TripImpl> {
		Logger.debug("\(tripIds.count) tripIds to query")
		
		var serviceIds = serviceIdCache[date]
        if serviceIds == nil {
            serviceIds = realm.allObjects(ofType: CalendarDateImpl.self).filter(using: "date == %@", date).map { $0.serviceId }
            serviceIdCache[date] = serviceIds
        }
		
        let trips: Results<TripImpl>
        if let direction = directionId {
            trips = realm.allObjects(ofType: TripImpl.self)
                .filter(using: "_directionId == %@ AND id IN %@ AND serviceId IN %@", direction, tripIds, serviceIds!)
        } else {
            trips = realm.allObjects(ofType: TripImpl.self)
                .filter(using: "id IN %@ AND serviceId IN %@", tripIds, serviceIds!)
        }
        
		Logger.debug("found \(trips.count) trips")
		return trips
	}
    
    private func findTransfers(fromTripIds: Set<String>, toTripIds:Set<String>, on date: Date, realm: Realm) -> [TripSummary] {
        
        let fromTrips = findTrips(with: fromTripIds, on: date, realm: realm)
        let toTrips = findTrips(with: toTripIds, on: date, realm: realm)
        
        let stops = realm.allObjects(ofType: StopImpl.self).filter(using: "routes.@count > 1")
        let stopIds: [Int] = stops.map { $0.id }
        let stopTimes = realm.allObjects(ofType: StopTimeImpl.self).filter(using: "stopId IN %@", stopIds).groupBy { $0.stopId }
        
        
        
        
        return []
    }
		
}
