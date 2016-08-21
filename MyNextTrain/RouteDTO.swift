//
//  RouteDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

struct RouteDTO {
	
    let id: Int
	let longName: String
	
}

extension RouteDTO: GTFSFileEntry {
    
    init(columnMap: [String : String]) {
        self.id = Int(columnMap["route_id"]!)!
        self.longName = columnMap["route_long_name"]!
    }
    
    var lookupKey: AnyHashable {
        return AnyHashable(id)
    }
    
}
