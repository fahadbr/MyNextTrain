//
//  RouteImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/23/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift

class RouteImpl: Object, Route, GTFSFileEntry {
	
	dynamic var id: Int = 0
	dynamic var shortName: String = ""
	dynamic var longName: String = ""
	dynamic var type: Int = 0
	dynamic var color: String?
	dynamic var textColor: String?
	
	func apply(row: GTFSFileRow) {
		row.bind(column: "route_id", to: &id)
		row.bind(column: "route_short_name", to: &shortName)
		row.bind(column: "route_long_name", to: &longName)
		row.bind(column: "route_type", to: &type)
		row.bind(column: "route_text_color", to: &textColor)
		row.bind(column: "route_color", to: &color)
	}
	
	override class func primaryKey() -> String? {
		return "id"
	}
}
