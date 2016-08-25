//
//  Trip.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/17/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol Trip {
	
    var id: String { get }
    var routeId: Int { get }
    var serviceId: String { get }
	var headSign: String { get }
	var directionId: Int { get }
	var shortName: String { get }
	var shapeId: String { get }
}
