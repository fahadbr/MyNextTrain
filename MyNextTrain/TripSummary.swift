//
//  TripSummary.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol TripSummary {
    
    var startingStop: StopTime { get }
    var destinationStop: StopTime { get }
    var trip: Trip { get }

}
