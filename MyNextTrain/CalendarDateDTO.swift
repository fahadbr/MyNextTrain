//
//  CalendarDateDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/19/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    $0.dateFormat = "yyyyMMdd"
    return $0
}(DateFormatter())

struct CalendarDateDTO {
	
	let date: Date 
    let serviceId: String 
	
}

extension CalendarDateDTO: GTFSFileEntry{
    
    init(columnMap: [String : String]) {
        self.date = dateFormatter.date(from: columnMap["date"]!)!
        self.serviceId = columnMap["service_id"]!
    }
    
    var lookupKey: AnyHashable {
        return AnyHashable(date)
    }
    
}
