//
//  GTFSFileEntry.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/21/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

protocol GTFSFileEntry {
	
	init()
    
    func apply(row: GTFSFileRow)
	
}
