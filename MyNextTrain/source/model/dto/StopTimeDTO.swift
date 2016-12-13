//
//  StopTimeDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation


struct StopTimeDTO: StopTime {
	
    let tripId: String 
	let arrivalTime: TimeInterval
	let departureTime: TimeInterval
    let stopId: Int 
    let stopSequence: Int 
	
}
