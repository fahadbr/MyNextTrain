//
//  TransferStopTimeImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/23/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RealmSwift


class TransferStopTimeImpl: Object, StopTime {
    
    dynamic var tripId: String = ""
    dynamic var arrivalTime: TimeInterval = 0
    dynamic var departureTime: TimeInterval = 0
    dynamic var stopId: Int = 0
    dynamic var stopSequence: Int = 0
    
    let transferTripSummary = LinkingObjects(fromType: TransferTripSummaryImpl.self, property: "transferStopTime")
    
    
    override class func indexedProperties() -> [String] {
        return ["stop_id"]
    }
    
}
