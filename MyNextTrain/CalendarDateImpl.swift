//
//  CalendarDateImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/30/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift

private let dateFormatter: DateFormatter = {
	$0.dateFormat = "yyyyMMdd"
	return $0
}(DateFormatter())

class CalendarDateImpl: Object, CalendarDate, GTFSFileEntry {
	
	dynamic var date: Date = Date.defaultValue
	dynamic var serviceId: String = String.defaultValue
	dynamic var exceptionType: Int = Int.defaultValue
	
	func apply(row: GTFSFileRow) {
		row.bind(column: "service_id", to: &serviceId)
		row.bind(column: "date", to: &date)
		row.bind(column: "exception_type", to: &exceptionType)
	}
	
}
