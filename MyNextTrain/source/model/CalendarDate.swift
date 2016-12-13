//
//  CalendarDate.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/19/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol CalendarDate {
	
	var date: Date { get }
    var serviceId: String { get }
	var exceptionType: Int { get }
	
}
