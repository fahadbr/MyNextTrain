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
	
    private lazy var routesById: [Int : Route] = self.loadRoutesById()
    private var serviceIdCache = [Date : [String]]()
    
	var favoritePairings: [StopPairing] {
		do {
			let realm = try Realm()
			let stopPairings: [StopPairing] = realm.objects(StopPairingImpl.self)
                .map( { StopPairingDTO($0) })
			
			return stopPairings
		} catch let e {
			Logger.error("error with fetching all stopPairings", error: e)
		}
		return []
	}
	
	var allStops: [Stop] {
		do {
			let realm = try Realm()
			let stops: [Stop] = realm.objects(StopImpl.self)
				.sorted(byProperty: "name")
                .map( { StopDTO(stop: $0) } )
			
			return stops
		} catch let e {
			Logger.error("error with fetching all stops", error: e)
		}
		return []
	}
    
    
	
    private func loadRoutesById() -> [Int : Route] {
        do {
            let realm = try Realm()
            let routes = realm.objects( RouteImpl.self).map { RouteDTO(route: $0) }
            Logger.debug("loaded \(routes.count) routes")
            return routes.dictionary(keyExtractor: { $0.id })
        
        } catch let e {
            Logger.error("error fetching routes", error: e)
        }
        return [:]
    }
	
	func tripSummaries(for pairing: StopPairing, on date: Date) -> [TripSummary] {
        let fromStop = pairing.fromStop
        let toStop = pairing.toStop
		
		do {
			let realm = try Realm()
			Logger.debug("searching using stops from \(fromStop.name) to \(toStop.name) for date \(date)")
			
            func stopTimes(forStop stop: Stop) -> [String : StopTimeImpl] {
                return realm.objects( StopTimeImpl.self).filter("stopId == \(stop.id)").dictionary { $0.tripId }
            }
            
			let fromStopTimes = stopTimes(forStop: fromStop)
			let toStopTimes = stopTimes(forStop: toStop)
            
            let fromTripIds = Set<String>(fromStopTimes.keys)
            let toTripIds = Set<String>(toStopTimes.keys)
            
            let commonTripIds = fromTripIds.intersection(toTripIds)
            
			let trips = findTrips(with: commonTripIds, on: date, directionId: pairing.directionId, realm: realm)
            

            
			
			var summaries: [TripSummary] = trips.map { trip -> DirectTripSummaryDTO in
				let stopTimes = Pair<StopTime>(fromStopTimes[trip.id]!, toStopTimes[trip.id]!)
				return DirectTripSummaryDTO(stopTimes: stopTimes,
				                            trip: trip,
				                            route: self.routesById[trip.routeId]!)
            }
			
            
            let transfers = findTransfers(fromStop: fromStop,
                                          fromTripIds: fromTripIds.subtracting(toTripIds),
                                          toStop: toStop,
                                          toTripIds: toTripIds.subtracting(fromTripIds),
                                          on: date,
                                          realm: realm)
            
            Logger.debug("FOUND \(transfers.count) TRANSFERS")
            summaries += transfers
            
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
        let fromStop = pairing.fromStop
        let toStop = pairing.toStop

        do {
            let realm = try Realm()
            Logger.debug("searching for next trip from \(fromStop.name) to \(toStop.name) on \(date)")
            
            let fromStopTimes = realm.objects( StopTimeImpl.self)
                .filter("stopId == %@ AND departureTime >= %@", fromStop.id, timeInterval)
                .sorted(byProperty: "departureTime")
            
            let toStopTimes = realm.objects( StopTimeImpl.self)
                .filter("stopId == %@ AND arrivalTime >= %@", toStop.id, timeInterval)
                .sorted(byProperty: "arrivalTime")
            
            let commonTripIds = Set<String>(fromStopTimes.map { $0.tripId })
                .intersection(Set<String>(toStopTimes.map { $0.tripId } ))
            
            let trips = findTrips(with: commonTripIds, on: date, directionId: pairing.directionId, realm: realm)
            
            let resultTripIds: [String] = trips.map { $0.id }
            
            guard let fromStopTime =  fromStopTimes.filter("tripId IN %@", resultTripIds).first else {
                Logger.debug("no starting stop time for pairing \(pairing.description)")
                return nil
            }
            
            guard let toStopTime = toStopTimes.filter("tripId == %@ AND stopSequence > %@",
                                                                        fromStopTime.tripId, fromStopTime.stopSequence).first else {
                Logger.debug("no destination stop time found for pairing \(pairing.description)")
                return nil
            }
            
            guard let trip = trips.filter("id == %@", fromStopTime.tripId).first else {
                Logger.error("why cant i find a trip what \(pairing.description)")
                return nil
            }
			
			let stopTimes = Pair<StopTime>(fromStopTime, toStopTime)
			let summary = DirectTripSummaryDTO(stopTimes: stopTimes, trip: trip, route: routesById[trip.routeId]!)
            
            return summary
            
        } catch let error {
            Logger.error("error with finding trips", error: error)
        }
        
        return nil
    }
	
    func findTrips(with tripIds: Set<String>, on date: Date, directionId: Int? = nil, realm: Realm) -> Results<TripImpl> {
		Logger.debug("\(tripIds.count) tripIds to query")
		
		let serviceIds = findServiceIds(for: date, realm: realm)
		var trips = realm.objects( TripImpl.self).filter("id IN %@ AND serviceId IN %@", tripIds, serviceIds)
		
		if let direction = directionId {
			trips = trips.filter("_directionId == %@", direction)
        }
        
		Logger.debug("found \(trips.count) trips")
		return trips
	}
	
	private func findServiceIds(for date: Date, realm: Realm) -> [String] {
		if let serviceIds = serviceIdCache[date] {
			return serviceIds
		}
		
		let serviceIds: [String] = realm.objects( CalendarDateImpl.self).filter("date == %@", date).map { $0.serviceId }
		serviceIdCache[date] = serviceIds
		
		return serviceIds
	}
	
    private func findTransfers(for pairing: StopPairing, on date: Date, realm: Realm) -> [TripSummary] {

        let fromTripIds: Set<String> = ((pairing.fromStop as? StopImpl)?.stopTimes.mapToSet { $0.tripId }) ?? []
        let toTripIds: Set<String>  = ((pairing.toStop as? StopImpl)?.stopTimes.mapToSet { $0.tripId }) ?? []
        
        return measure("find transfers non linked") {
                findTransfers(fromStop: pairing.fromStop,
                              fromTripIds: fromTripIds.subtracting(toTripIds),
                              toStop: pairing.toStop,
                              toTripIds: toTripIds.subtracting(fromTripIds),
                              on: date,
                              realm: realm)
        }
        
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
			for stopTime in realm.objects(StopTimeImpl.self).filter("tripId IN %@", Array(tripsById.keys)) {
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
                    let fromRoute = routesById[fromDTO.trip.routeId]!
                    let transfer = TransferTripSummaryDTO(
                        departureTime    : fromDTO.sourceStopTime.departureTime,
                        arrivalTime      : toDTO.sourceStopTime.arrivalTime,
                        transferStopName : stopsById[matchingStopTime.stopId]?.name ?? "unknown stop name",
                        transferTime     : Pair(matchingStopTime.departureTime, fromStopTime.arrivalTime),
                        fromRouteName    : fromRoute.longName,
                        fromRouteColor   : fromRoute.uiColor
                    )
					
					return transfer
				}
			}
			
			
			return nil
		}
        
        guard !fromTripIds.isEmpty && !toTripIds.isEmpty else { return [] }
        
        let fromTrips = findTrips(with: fromTripIds, on: date, realm: realm)
        let toTrips = findTrips(with: toTripIds, on: date, realm: realm)

        let fromTripStops = measure("find fromTripStops non-linked") {
            findTripStops(with: fromTrips, sourceStop: fromStop, realm: realm)
        }
        let toTripStops = measure("find toTripStops non-linked") {
            findTripStops(with: toTrips, sourceStop: toStop, realm: realm).lazy
                .map { $0.value }
                .sorted { $0.0.sourceStopTime.departureTime < $0.1.sourceStopTime.departureTime }

        }
					
		var transfers = [TimeInterval : TransferTripSummaryDTO]()
		
        measure("find connections non-linked") {
            for tripStop in fromTripStops {
                guard let transfer = findConnection(from: tripStop.value, in: toTripStops) else {
                    continue
                }
                
                
                let arrivalTime = transfer.arrivalTime
                
                //filter out trips which transfer to the same train another transfer but have a longer trip time
                if let existingTransfer = transfers[arrivalTime], existingTransfer.tripTime < transfer.tripTime {
                    continue
                }
                
                transfers[arrivalTime] = transfer
            }
        }
        
        
        return Array(transfers.values)
    }
		
}
