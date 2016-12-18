//
//  UpdateService.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol UpdateService {
	
	func addFavoritePairing(from fromStop: Stop, to toStop: Stop) throws
    
    func remove(pairing: StopPairing) throws

    func performMigrationIfNeeded()
    
    func setUpObjectLinks()
}
