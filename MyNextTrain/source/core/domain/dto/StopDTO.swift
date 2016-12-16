//
//  StopDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

struct StopDTO: Stop {
	
    let id: Int
	let name: String
	let latitude: Double
	let longitude: Double
    
}

extension StopDTO {
    
    init(columnMap: [String : String]) {
        self.id = Int(columnMap["stop_id"]!)!
        self.name = columnMap["stop_name"]!
        self.latitude = Double(columnMap["stop_lat"]!)!
        self.longitude = Double(columnMap["stop_lon"]!)!
    }

    init(stop: Stop) {
        self.id          = stop.id
        self.name        = stop.name
        self.latitude    = stop.latitude
        self.longitude   = stop.longitude
    }
    
    var lookupKey: AnyHashable {
        return AnyHashable(id)
    }
    
}
