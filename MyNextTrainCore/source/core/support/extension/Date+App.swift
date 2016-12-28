//
//  Date+Ext.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/17/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

fileprivate let secondsPerDay: TimeInterval = 3600 * 24
fileprivate let timeFormatter = DateFormatter(pattern: "hh:mma")

extension DateFormatter {

    public convenience init(pattern: String) {
        self.init()
        dateFormat = pattern
    }

}

extension Date {

    public func plus(days: TimeInterval) -> Date {
        return self + (secondsPerDay * days)
    }

    var timeRepresentation: String {
        var s = timeFormatter.string(from: self)
        if s[s.startIndex] == "0" {
            s.remove(at: s.startIndex)
        }
        return s
    }

    public static func -(lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }


}
