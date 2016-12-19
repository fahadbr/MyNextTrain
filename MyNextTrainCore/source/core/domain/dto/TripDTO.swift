//
//  TripDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/17/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

struct TripDTO {
	
    let id: String 
    let routeId: Int 
    let serviceId: String 
	let headSign: String
	let directionId: Int 
}

extension TripDTO {
    
    init(columnMap: [String : String]) {
        self.id = columnMap["trip_id"]!
        self.routeId = Int(columnMap["route_id"]!)!
        self.serviceId = columnMap["service_id"]!
        self.headSign = columnMap["trip_headsign"]!
        self.directionId = Int(columnMap["direction_id"]!)!
    }
    
    var lookupKey: AnyHashable {
        return AnyHashable("\(routeId)\(serviceId)")
    }
    
}
