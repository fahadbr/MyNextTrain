//
//  DoubleExtension.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

let timeFormatter: DateFormatter = {
	$0.dateFormat = "hh:mm:ss a"
	return $0
}(DateFormatter())

extension Double {
    
    //assuming the value represents seconds
    var timeRepresentation: String {
        guard self != Double.nan && self != Double.infinity && self > 0 else {
            return "0s"
        }
        
        let i = Int(self)
        let hours = i / 3600
        let minutes = i % 3600 / 60
        let seconds = i % 60
        
        let h = hours > 0 ? "\(hours)h " : ""
        let m = minutes > 0  || !h.isEmpty ? "\(minutes)m " : ""
        let s = hours == 0 && minutes < 30 ? "\(seconds)s" : ""
        
        return "\(h)\(m)\(s)"
    }
	
	func timeRepresenation(from date: Date) -> String {
		return timeFormatter.string(from: date.addingTimeInterval(self))
	}
    
}
