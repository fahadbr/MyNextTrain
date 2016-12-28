//
//  DoubleExtension.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

fileprivate let timeFormatter = DateFormatter(pattern: "hh:mma")

extension Double {
    
	/// Returns a string representation of self in the form of hours minutes and seconds
    /// assuming self represents an absolute time interval of seconds
    /// e.g. if self is 3661 this would return 1h 1m 1s
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
