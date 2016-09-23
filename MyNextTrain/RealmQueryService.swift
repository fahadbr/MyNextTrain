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
            
			let transfers = findTransfers(fromStop: startingStop,
			                      fromTripIds: fromTripIds.subtracting(toTripIds),
			                      toStop: destinationStop,
			                      toTripIds: toTripIds.subtracting(fromTripIds),
                                  on: date,
                                  realm: realm)
            Logger.debug("FOUND \(transfers.count) TRANSFERS")
			
			var summaries: [TripSummary] = trips.map { trip -> DirectTripSummaryDTO in
				let stopTimes = FromToPair<StopTime>(from: startingStopTimes[trip.id]!, to: destinationStopTimes[trip.id]!)
				return DirectTripSummaryDTO(stopTimes: stopTimes,
				                            trip: trip,
				                            route: self.routesById[trip.routeId]!)
            }
			
			summaries.append(contentsOf: transfers)
            
            Logger.debug("found \(summaries.count) summaries")
            return summaries.sorted { $0.0.departureTime < $0.1.departureTime }
			
		} catch let error {
			Logger.error("error with finding trips", error: error)
		}
		
		return []
	}
	
	func nextTripSummary(forPairing pairing: StopPairing) -> (isForTomorrow: Bool, summary:TripSummary)? {
        let date = currentDate
        let currentTimeInterval = Date().timeIntervalSince(date)
		if let summary = tripSummaries(for: pairing, on: date).first(where: { $0.departureTime > currentTimeInterval }) {
            return (false, summary)
        }
        
        let nextDate = date + (3600 * 24)
        if let nextDayTripSummary =  tripSummaries(for: pairing, on: nextDate).first(where: { $0.departureTime > currentTimeInterval }){
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
			
			let stopTimes = FromToPair<StopTime>(from: startingStopTime, to: destinationStopTime)
			let summary = DirectTripSummaryDTO(stopTimes: stopTimes, trip: trip, route: routesById[trip.routeId]!)
            
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
		
		var trips = realm.allObjects(ofType: TripImpl.self).filter(using: "id IN %@ AND serviceId IN %@", tripIds, serviceIds!)
		
		if let direction = directionId {
			trips = trips.filter(using: "_directionId == %@", direction)
        }
        
		Logger.debug("found \(trips.count) trips")
		return trips
	}
    
	private func findTransfers(fromStop: Stop,
	                           fromTripIds: Set<String>,
	                           toStop: Stop,
	                           toTripIds:Set<String>,
	                           on date: Date,
	                           realm: Realm) -> [TripSummary] {
		
		class TransferDTO {
			var sourceStopTime: StopTimeImpl!
			var trip: Trip!
			var tripStopTimes = [StopTimeImpl]()
		}
		
		func findTripStops(with trips: Results<TripImpl>, sourceStop: Stop, realm: Realm) -> [String : TransferDTO] {
			let tripsById = trips.dictionary { $0.id }
			var tripStops = [String : TransferDTO]()
			
			let defaultCompute = { TransferDTO() }
			for stopTime in realm.allObjects(ofType: StopTimeImpl.self).filter(using: "tripId IN %@", Array(tripsById.keys)) {
				let transferDTO = tripStops.get(key: stopTime.tripId, or: defaultCompute)
					
				if stopTime.stopId == sourceStop.id {
					transferDTO.sourceStopTime = stopTime
				}
				if transferDTO.trip == nil {
					transferDTO.trip = tripsById[stopTime.tripId]
				}
				transferDTO.tripStopTimes.append(stopTime)
			}
			
			tripStops.forEach {
				$0.value.tripStopTimes.sort(by: { $0.0.stopId < $0.1.stopId })
			}
			
			
			
			return tripStops
		}
        
        let fromTrips = findTrips(with: fromTripIds, on: date, realm: realm)
        let toTrips = findTrips(with: toTripIds, on: date, realm: realm)
		let stopsById = self.allStops.dictionary { $0.id }
		
		func findConnection(from fromDTO: TransferDTO, in toDTOs: [TransferDTO]) -> TransferTripSummaryDTO? {
			for toDTO in toDTOs {
				guard fromDTO.sourceStopTime.departureTime < toDTO.sourceStopTime.arrivalTime else { continue }
				
				for fromStopTime in fromDTO.tripStopTimes {
					guard fromStopTime.stopSequence > fromDTO.sourceStopTime.stopSequence,
						let matchingStopTime = toDTO.tripStopTimes.first(where: { $0.stopId == fromStopTime.stopId && fromStopTime.arrivalTime < $0.departureTime} ),
						matchingStopTime.stopSequence < toDTO.sourceStopTime.stopSequence else {
						continue
					}
					let transfer = TransferTripSummaryDTO()
					transfer.stopTimes = FromToPair(from: fromDTO.sourceStopTime, to: toDTO.sourceStopTime)
					transfer.trips = FromToPair(from: fromDTO.trip, to: toDTO.trip)
					transfer.routes = FromToPair(from: routesById[fromDTO.trip.routeId]!, to: routesById[toDTO.trip.routeId]!)
					transfer.transferStopTime = StopTimeDTO(tripId: "\(fromDTO.trip.id),\(toDTO.trip.id)",
						arrivalTime: fromStopTime.arrivalTime,
						departureTime: matchingStopTime.departureTime,
						stopId: matchingStopTime.stopId,
						stopSequence: fromStopTime.stopSequence)
					transfer.transferStop = stopsById[matchingStopTime.stopId]
					return transfer
				}
			}
			
			
			return nil
		}

		let fromTripStops = findTripStops(with: fromTrips, sourceStop: fromStop, realm: realm)
		let toTripStops = findTripStops(with: toTrips, sourceStop: toStop, realm: realm).lazy
			.map { $0.value }
			.sorted { $0.0.sourceStopTime.departureTime < $0.1.sourceStopTime.departureTime }
		
		var transfers = [TransferTripSummaryDTO]()
		
		for tripStop in fromTripStops {
			if let transfer = findConnection(from: tripStop.value, in: toTripStops) {
				transfers.append(transfer)
			}
		}
        
        
        
        return transfers
    }
		
}
