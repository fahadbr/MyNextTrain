//
//  DoubleExtension.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

let timeFormatter: DateFormatter = {
	$0.dateFormat = "hh:mma"
	return $0
}(DateFormatter())

extension Double {
    
    //assuming the value represents seconds
    var timeRepresentation: String {
        guard self != Double.nan && self != Double.infinity && self > 0 else {
            return "0s"
        }
        
        let i = Int(self)
        let hours = i.hours
        let minutes = i.minutesOnTheHour
        let seconds = i.secondsOnTheMinute
        
        var components = [String]()
        
        if hours > 0 {
            components.append("\(hours)h")
        }
        if minutes > 0 {
            components.append("\(minutes)m")
        }
        if hours == 0 && minutes < 15 {
            components.append("\(seconds)s")
        }
        
        return components.joined(separator: " ")
    }
	
	func timeRepresenation(from date: Date) -> String {
		var s = timeFormatter.string(from: date.addingTimeInterval(self))
        if s[s.startIndex] == "0" {
            s.remove(at: s.startIndex)
        }
        return s
	}
    
}

extension Int {
    
    var hours: Int {
        return self / 3600
    }
    
    var minutesOnTheHour: Int {
        return self % 3600 / 60
    }
    
    var minutes: Int {
        return self / 60
    }
    
    var secondsOnTheMinute: Int {
        return self % 60
    }
    
}
