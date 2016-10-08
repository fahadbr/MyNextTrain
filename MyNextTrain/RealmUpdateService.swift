//
//  RealmUpdateService.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RealmSwift

class RealmUpdateService: UpdateService {
    
    lazy var queryService = AppDelegate.queryService
	
	func addFavoritePairing(from startingStop: Stop, to destinationStop: Stop) throws {

		
		guard let startObj = startingStop as? StopImpl, let destObj = destinationStop as? StopImpl else {
			throw ErrorDTO(description: "require type StopPairingImpl in order to persist")
		}
        let startTime = CFAbsoluteTimeGetCurrent()
        let desc = "[\(startObj.name) - \(destObj.name)]"
        Logger.debug("starting to add pairing \(desc)")
        
		
		let realmObj = StopPairingImpl()
		realmObj._startingStop = startObj
		realmObj._destinationStop = destObj
        
        
		
		let realm = try Realm()
//        let transfers = findTransfers(from: startObj, to: destObj, realm: realm)
		
//        realmObj.transferTripSummaries.append(objectsIn: transfers)
		
		try realm.write {
			realm.add(realmObj)
		}
		
		Logger.debug("took \(CFAbsoluteTimeGetCurrent() - startTime) to add pairing \(desc)")
	}
    
    func remove(pairing: StopPairing) throws {
        guard let realmObj = pairing as? StopPairingImpl else {
            throw ErrorDTO(description: "require type StopPairingImpl in order to delete")
        }
        
        //need this before deleting because otherwise it will print "invalid object" if we get description after deleting
        let debugMessage = "deleted pairing [\(pairing.startingStop.name) - \(pairing.destinationStop.name)]"
        
        let realm = try Realm()
        
//        let reversedPairing = realm.objects(StopPairingImpl.self).filter("_startingStop.id == %@ && _destinationStop.id == %@", pairing.destinationStop.id, pairing.startingStop.id).first
        
        try realm.write {
//            if reversedPairing == nil{
//            realmObj.transferTripSummaries.forEach {
//                realm.delete($0.transferStopTime)
//            }
//            
//            realm.delete(realmObj.transferTripSummaries)
//            }
            
            realm.delete(realmObj)
        }
        
        Logger.debug(debugMessage)
    }
    
    func performMigrationIfNeeded() {
        let newSchemaVersion: UInt64 = 4
        let config = Realm.Configuration(schemaVersion: newSchemaVersion, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < newSchemaVersion) {
                Logger.debug("migrating to new realm schema")
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    func setUpObjectLinks() {
        guard AppDelegate.overrideReload else {
            return
        }
        
        do {
            let realm = try Realm()
            for stop in realm.objects(StopImpl.self) {
                let stopTimes = realm.objects(StopTimeImpl.self).filter("stopId == %@", stop.id)
                try realm.write {
                    stop.stopTimes.append(objectsIn: stopTimes)
                }
            }
            
            for trip in realm.objects(TripImpl.self) {
                let stopTimes = realm.objects(StopTimeImpl.self).filter("tripId == %@", trip.id)
                try realm.write {
                    trip.stopTimes.append(objectsIn: stopTimes)
                }
            }
            
        } catch let e {
            Logger.error("error setting up object links", error: e)
        }
    }
    
    private func findTransfers(from fromStop: StopImpl, to toStop: StopImpl, realm: Realm) -> [TransferTripSummaryImpl] {
        class TransferDTO {
            var sourceStopTime: StopTimeImpl!
            var trip: TripImpl!
            var tripStopTimes: [StopTimeImpl]!
        }
        
        let emptyTrip = TripImpl()
        let allFromTrips = fromStop.stopTimes.mapToSet { $0.trip.first ?? emptyTrip }
        let allToTrips = toStop.stopTimes.mapToSet { $0.trip.first ?? emptyTrip }
        let fromTrips = allFromTrips.subtracting(allToTrips).subtracting([emptyTrip])
        let toTrips = allToTrips.subtracting(allFromTrips).subtracting([emptyTrip])

        
        func findTripStops(with trips: Set<TripImpl>, sourceStop: StopImpl, realm: Realm) -> [TransferDTO] {
            
            return trips.map { trip in
                let dto = TransferDTO()
                dto.trip = trip
                let stopTimes = trip.stopTimes.sorted(by: { $0.0.stopSequence < $0.1.stopSequence })
                dto.tripStopTimes = stopTimes
                dto.sourceStopTime = stopTimes.first { $0.stopId == sourceStop.id }
                return dto
            }
            
        }
        
        let stopsById = queryService.allStops.dictionary { $0.id }
        let routesById = realm.objects(RouteImpl.self).dictionary { $0.id }
        
        func findConnection(from fromDTO: TransferDTO, in toDTOs: [TransferDTO]) -> TransferTripSummaryImpl? {
            for toDTO in toDTOs {
                guard fromDTO.trip.serviceId == toDTO.trip.serviceId,
					fromDTO.sourceStopTime.departureTime < toDTO.sourceStopTime.arrivalTime else { continue }
                
                for fromStopTime in fromDTO.tripStopTimes {
                    guard fromStopTime.stopSequence > fromDTO.sourceStopTime.stopSequence,
                        let matchingStopTime = toDTO.tripStopTimes.first(where: { $0.stopId == fromStopTime.stopId && fromStopTime.arrivalTime < $0.departureTime} ),
                        matchingStopTime.stopSequence < toDTO.sourceStopTime.stopSequence else {
                            continue
                    }
					
					
//					if fromDTO.trip.serviceId != toDTO.trip.serviceId {
//						let serviceIdPair = [fromDTO.trip.serviceId, toDTO.trip.serviceId]
//						let calendarDates = realm.objects(CalendarDateImpl.self)
//							.filter("serviceId IN %@",  serviceIdPair)
//							.sorted(byProperty: "date")
//						
//						var currentDate: Date!
//						var count = 0
//						for calendarDate in calendarDates {
//							if currentDate == nil || currentDate != calendarDate.date {
//								currentDate = calendarDate.date
//								count = 1
//							} else {
//								count = 2
//								break
//							}
//						}
//						
//						guard count == 2 else {
//							Logger.debug("calendar count is \(count)")
//							continue
//						}
//					} else {
//						Logger.debug("serviceIds are equal")
//					}
					
                    let transfer = TransferTripSummaryImpl()
                    transfer.fromStopTime = fromDTO.sourceStopTime
                    transfer.toStopTime = toDTO.sourceStopTime
                    transfer.fromTrip = fromDTO.trip
                    transfer.toTrip = toDTO.trip
                    transfer.fromRoute = routesById[fromDTO.trip.routeId]
                    transfer.toRoute = routesById[toDTO.trip.routeId]
                    transfer.transferStop = matchingStopTime.stop.first
                    let transferStopTime = TransferStopTimeImpl()
                    transferStopTime.tripId = "\(fromDTO.trip.id),\(toDTO.trip.id)"
                    transferStopTime.arrivalTime = fromStopTime.arrivalTime
                    transferStopTime.departureTime = matchingStopTime.departureTime
                    transferStopTime.stopId = matchingStopTime.stopId
                    transferStopTime.stopSequence = fromStopTime.stopSequence
                    transfer.transferStopTime = transferStopTime
                    
                    return transfer
                }
            }
            
            
            return nil
        }
        
        let fromTripStops = measure("find fromTripStops") {
            findTripStops(with: fromTrips, sourceStop: fromStop, realm: realm)
        }
        let toTripStops = measure("find toTripStops") {
            findTripStops(with: toTrips, sourceStop: toStop, realm: realm).lazy
            .sorted { $0.0.sourceStopTime.departureTime < $0.1.sourceStopTime.departureTime }
        }
        
        var transfers = [String : TransferTripSummaryImpl]()
        measure("find connections") {
            for tripStop in fromTripStops {
                guard let transfer = findConnection(from: tripStop, in: toTripStops) else {
                    continue
                }
                
                
                let toTripId = transfer.toTrip?.id ?? ""
                
                //filter out trips which transfer to the same train another transfer but have a longer trip time
                if let existingTransfer = transfers[toTripId], existingTransfer.tripTime < transfer.tripTime {
                    continue
                }
                
                transfers[toTripId] = transfer
            }
        }
        
        
        
        return Array(transfers.values)
    }

}

func measure<T>(_ actionName:String, _ block: () -> T ) -> T{
    let startTime = CFAbsoluteTimeGetCurrent()
    let value = block()
    Logger.debug("took \(CFAbsoluteTimeGetCurrent() - startTime) to perform \(actionName)")
    return value
}
