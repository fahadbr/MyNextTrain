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
    
    init(stop: Stop) {
        self.id          = stop.id
        self.name        = stop.name
        self.latitude    = stop.latitude
        self.longitude   = stop.longitude
    }
    
}
