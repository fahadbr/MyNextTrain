//
//  TripImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/23/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift

class TripImpl: Object, Trip, GTFSFileEntry {
	
	dynamic var id: String = ""
	dynamic var routeId: Int = 0
	dynamic var serviceId: String = ""
	dynamic var headSign: String = ""
	dynamic var directionId: Int = 0
	dynamic var shortName: String = ""
	dynamic var shapeId: String = ""
	
	func apply(row: GTFSFileRow) {
		row.bind(column: "trip_id", to: &id)
		row.bind(column: "route_id", to: &routeId)
		row.bind(column: "service_id", to: &serviceId)
		row.bind(column: "trip_headsign", to: &headSign)
		row.bind(column: "trip_short_name", to: &shortName)
		row.bind(column: "direction_id", to: &directionId)
		row.bind(column: "shape_id", to: &shapeId)
	}
	
	override class func primaryKey() -> String? {
		return "id"
	}
	
}