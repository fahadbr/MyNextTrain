//
//  StopTime.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol StopTime {
	
	var arrivalTime: Date { get }
	var departureTime: Date { get }
	var stop: Stop { get }
	
}
