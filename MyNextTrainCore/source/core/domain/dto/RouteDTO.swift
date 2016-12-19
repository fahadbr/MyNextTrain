//
//  RouteDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

struct RouteDTO: Route {
	
    let id: Int
	let shortName: String
	let longName: String
	let type: Int
	let color: String?
	let textColor: String?
}

extension RouteDTO {

    init(route: Route) {
        id        = route.id
        shortName = route.shortName
        longName  = route.longName
        type      = route.type
        color     = route.color
        textColor = route.textColor
    }

}
