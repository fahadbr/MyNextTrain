//
//  Date+Ext.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/17/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

extension DateFormatter {

    convenience init(pattern: String) {
        self.init()
        dateFormat = pattern
    }

}

