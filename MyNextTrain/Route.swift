//
//  Route.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift

protocol Route {
	
    var id: Int { get }
	var shortName: String { get }
	var longName: String { get }
	var type: Int { get }
	var color: String? { get }
	var textColor: String? { get }
	
}

protocol MutableRoute: Route, GTFSFileEntry {
	
	var id: Int { get set }
	var shortName: String { get set }
	var longName: String { get set }
	var type: Int { get set }
	var color: String? { get set }
	var textColor: String? { get set }
	
}

extension MutableRoute {
	
	mutating func apply(columnMap: [String : String]) {
		self.id = columnMap["route_id"]!.int
		self.shortName = columnMap["route_short_name"]!
		self.longName = columnMap["route_long_name"]!
		self.type = columnMap["route_type"]!.int
		self.color = columnMap["route_color"]
		self.textColor = columnMap["route_text_color"]
	}

}
