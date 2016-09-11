//
//  TripSummaryImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

class TripSummaryImpl: TripSummary {

    dynamic var _startingStop: StopTimeImpl!
    dynamic var _destinationStop: StopTimeImpl!
    dynamic var _trip: TripImpl!
    dynamic var _route: RouteImpl!
    
    var startingStop: StopTime { return _startingStop }
    var destinationStop: StopTime { return _destinationStop }
    var trip: Trip { return _trip }
    var route: Route { return _route }

    
}
