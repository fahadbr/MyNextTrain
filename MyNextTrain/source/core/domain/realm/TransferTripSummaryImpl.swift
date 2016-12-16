//
//  TransferTripSummaryImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/23/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RealmSwift

class TransferTripSummaryImpl: Object {
    
    var tripTime: TimeInterval {
        return toStopTime.arrivalTime - fromStopTime.departureTime
    }
    
    override var hashValue: Int {
        return _hash
    }
    
    dynamic var fromStopId: Int = 0
    dynamic var toStopId: Int = 0
    
    dynamic var fromStopTime: StopTimeImpl! {
        didSet {
            fromStopId = fromStopTime?.stopId ?? 0
        }
    }
    dynamic var toStopTime: StopTimeImpl! {
        didSet {
            toStopId = toStopTime?.stopId ?? 0
        }
    }
    dynamic var fromTrip: TripImpl!
    dynamic var toTrip: TripImpl!
    dynamic var fromRoute: RouteImpl!
    dynamic var toRoute: RouteImpl!
    dynamic var transferStopTime: TransferStopTimeImpl!
    dynamic var transferStop: StopImpl!
    
    private lazy var _hash: Int = self.generateHash()
    
    private func generateHash() -> Int {
        return "\(fromTrip?.id ?? "")-\(toTrip?.id ?? "")-\(transferStop?.id ?? 0)".hashValue
    }

}
