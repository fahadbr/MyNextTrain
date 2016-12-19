//
//  Stop.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

public protocol Stop {
	
    var id: Int { get }
	var name: String { get }
	var latitude: Double { get }
	var longitude: Double { get }
    
}
