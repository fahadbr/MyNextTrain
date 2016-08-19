//
//  Route.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol Route {
	
	var shortName: String { get }
	var longName: String { get }
	var type: String { get }
	var color: String { get }
	var textColor: String { get }
	var trips: [Trip] { get }
	
}
