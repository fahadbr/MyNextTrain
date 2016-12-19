//
//  StopImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/23/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift

class StopImpl: Object, Stop, GTFSFileEntry {
	
	dynamic var id: Int = 0
	dynamic var name: String = ""
	dynamic var latitude: Double = 0
	dynamic var longitude: Double = 0
    
    let stopTimes = List<StopTimeImpl>()
	
	func apply(row: GTFSFileRow) {
		row.bind(column: "stop_id", to: &id)
		row.bind(column: "stop_name", to: &name)
		row.bind(column: "stop_lat", to: &latitude)
		row.bind(column: "stop_lon", to: &longitude)
	}
	
	override class func primaryKey() -> String? {
		return "id"
	}

    static func copy(_ stop: Stop) -> StopImpl {
        let s = StopImpl()
        s.id          = stop.id
        s.name        = stop.name
        s.latitude    = stop.latitude
        s.longitude   = stop.longitude
        return s
    }
	
}

