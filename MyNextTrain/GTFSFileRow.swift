//
//  GTFSFileRow.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/23/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

struct GTFSFileRow {
	
	let columnMap: [String : String]
	
	init(names: [String], values: [String]) {
		var map = [String : String]()
		values.enumerated().forEach {
			map[names[$0.offset]] = $0.element
		}
		columnMap = map
	}
	
	func bind<T: GTFSMappable>(column: String, to field: inout T)  {
		guard let value = columnMap[column] else {
			field = T.defaultValue
			return
		}
		
		field = T.valueOf(value) ?? T.defaultValue
	}
	
	func bind<T: GTFSMappable>(column: String, to field: inout T?)  {
		guard let value = columnMap[column] else {
			field = T.defaultValue
			return
		}
		
		field = T.valueOf(value)
	}
	
	
}

protocol GTFSMappable {
	
	static func valueOf(_ string: String) -> Self?
	
	static var defaultValue: Self { get }
	
}

extension Int: GTFSMappable {
	static func valueOf(_ string: String) -> Int? {
		return Int(string)
	}
	
	static var defaultValue: Int {
		return 0
	}
	
}

extension Double: GTFSMappable {
	
	static func valueOf(_ string: String) -> Double? {
        if let d = Double(string) {
            return d
        }
        let components = string.components(separatedBy: ":")
        var seconds: Double = 0
        
        for (i, value) in components.enumerated() {
            guard let number = Double(value) else { continue }
            
            var multiplier: Double = 1
            switch i {
            case 0:
                multiplier = 3600
            case 1:
                multiplier = 60
            default:
                multiplier = 1
            }
            
            seconds += (number * multiplier)
        }
        
        return seconds
	}
	
	static var defaultValue: Double {
		return 0
	}
	
}

extension String: GTFSMappable {
	
	static func valueOf(_ string: String) -> String? {
		return string
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
	
	static func valueOf(_ string: String) -> Date? {
		return Static.formatter.date(from: string)
	}
	
	static var defaultValue: Date {
		return Static.date
	}
	
}


