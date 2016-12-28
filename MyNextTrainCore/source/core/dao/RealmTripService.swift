//
//  RealmTripService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/24/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

/**
 @dip.register TripService
 @dip.scope Singleton
 @dip.constructor init()
 */
class RealmTripService: TripService {

    private lazy var routesById: [Int : Route] = self.loadRoutesById()
    private var serviceIdCache = [Date : [String]]()

    var favoritePairings: [StopPairing] {
        do {
            let realm = try Realm.gtfs()
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
            let realm = try Realm.gtfs()
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
            let realm = try Realm.gtfs()
            let routes = realm.objects( RouteImpl.self).map { RouteDTO(route: $0) }
            Logger.debug("loaded \(routes.count) routes")
            return routes.dictionary(keyExtractor: { $0.id })
            
        } catch let e {
            Logger.error("error fetching routes", error: e)
        }
        return [:]
    }

    func tripSummaries(for pairing: StopPairing, on date: Date) -> Observable<[TripSummary]> {
        return Observable.create {
            let tripSummaries = self._tripSummaries(for: pairing, on: date)
            $0.onNext(tripSummaries)
            $0.onCompleted()
            return Disposables.create()
        }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }


    private func _tripSummaries(for pairing: StopPairing, on date: Date) -> [TripSummary] {
        let fromStop = pairing.fromStop
        let toStop = pairing.toStop

        do {
            let realm = try Realm.gtfs()
            Logger.debug("searching using stops from \(fromStop.name) to \(toStop.name) for date \(date)")

            func stopTimes(forStop stop: Stop) -> [String : StopTimeImpl] {
                return realm.objects( StopTimeImpl.self).filter("stopId == \(stop.id)").dictionary { $0.tripId }
            }

            let fromStopTimes = stopTimes(forStop: fromStop)
            let toStopTimes   = stopTimes(forStop: toStop)

            let fromTripIds   = Set<String>(fromStopTimes.keys)
            let toTripIds     = Set<String>(toStopTimes.keys)

            let commonTripIds = fromTripIds.intersection(toTripIds)

            let trips = findTrips(with: commonTripIds, on: date, directionId: pairing.directionId, realm: realm)


            var summaries: [TripSummary] = trips.map { trip -> DirectTripSummaryDTO in
                return DirectTripSummaryDTO(departureTime: date + fromStopTimes[trip.id]!.departureTime,
                                            arrivalTime: date + toStopTimes[trip.id]!.arrivalTime,
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


    func findTrips(with tripIds: Set<String>, on date: Date, directionId: Int? = nil, realm: Realm) -> Results<TripImpl> {
        Logger.debug("\(tripIds.count) tripIds to query")

        let serviceIds = serviceIdCache.get(key: date) {
            realm.objects(CalendarDateImpl.self).filter("date == %@", date).map { $0.serviceId }
        }
        var trips = realm.objects( TripImpl.self).filter("id IN %@ AND serviceId IN %@", tripIds, serviceIds)

        if let direction = directionId {
            trips = trips.filter("_directionId == %@", direction)
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
                        departureTime    : date + fromDTO.sourceStopTime.departureTime,
                        arrivalTime      : date + toDTO.sourceStopTime.arrivalTime,
                        transferStopName : stopsById[matchingStopTime.stopId]?.name ?? "unknown stop name",
                        transferTime     : Pair(date + matchingStopTime.departureTime, date + fromStopTime.arrivalTime),
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

        let fromTripStops = findTripStops(with: fromTrips, sourceStop: fromStop, realm: realm)
        let toTripStops = findTripStops(with: toTrips, sourceStop: toStop, realm: realm).lazy
                .map { $0.value }
                .sorted { $0.0.sourceStopTime.departureTime < $0.1.sourceStopTime.departureTime }
        
        var transfers = [Date : TransferTripSummaryDTO]()

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
        
        
        return Array(transfers.values)
    }
}
