//
//  GTFSFileRow.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/23/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

struct GTFSFileRow {
	
	private let columnMap: [String : String]
	
	func bind<T: GTFSMappable>(column: String, to field: inout T)  {
		guard let value = columnMap[column] else {
			field = T.defaultValue
			return
		}
		
		field = T(value) ?? T.defaultValue
	}
	
	func bind<T: GTFSMappable>(column: String, to field: inout T?)  {
		guard let value = columnMap[column] else {
			field = T.defaultValue
			return
		}
		
		field = T(value)
	}
	
	
}

protocol GTFSMappable {
	
	init?(_ string: String)
	
	static var defaultValue: Self { get }
	
}

extension Int: GTFSMappable {
	init?(_ string: String) {
		self.init(string)
	}
	
	static var defaultValue: Int {
		return 0
	}
	
}

extension Double: GTFSMappable {
	
	init?(_ string: String) {
		self.init(string)
	}
	
	static var defaultValue: Double {
		return 0
	}
	
}

extension String: GTFSMappable {
	
	init?(_ string: String) {
		self.init(string)
	}
	
	static var defaultValue: String {
		return ""
	}
	
}


extension Date: GTFSMappable {
	
	private struct Static {
		static let date = Date()
		static let formatter: DateFormatter = {
			$0.dateFormat = "yyyyMMdd"
			return $0
		}(DateFormatter())
	}
	
	init?(_ string: String) {
		guard let date = Static.formatter.date(from: string) else {
			return nil
		}
		self = date
	}
	
	static var defaultValue: Date {
		return Static.date
	}
	
}


