//
//  Trip.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/17/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol Trip {
	
	var stopTimes: [StopTime] { get }
	var headSign: String { get }
	var shortName: String { get }
	var directionId: Int { get }
}
