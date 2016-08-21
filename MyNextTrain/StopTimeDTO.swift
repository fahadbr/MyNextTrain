//
//  StopTimeDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation


struct StopTimeDTO {
	
    let tripId: String 
	let arrivalTimeRaw: String
	let departureTimeRaw: String
    let stopId: Int 
    let stopSequence: Int 
	
}

extension StopTimeDTO: GTFSFileEntry {
    
    init(columnMap: [String : String]) {
        self.tripId = columnMap["trip_id"]!
        self.arrivalTimeRaw = columnMap["arrival_time"]!
        self.departureTimeRaw = columnMap["departure_time"]!
        self.stopId = Int(columnMap["stop_id"]!)!
        self.stopSequence = Int(columnMap["stop_sequence"]!)!
        
    }
    
    var lookupKey: AnyHashable {
        return AnyHashable(tripId)
    }
    
}
