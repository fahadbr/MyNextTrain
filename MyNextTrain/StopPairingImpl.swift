//
//  StopPairingImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RealmSwift

class StopPairingImpl: Object, StopPairing {
	
	dynamic var _startingStop: StopImpl?
	dynamic var _destinationStop: StopImpl?
    let transferTripSummaries = List<TransferTripSummaryImpl>()
	
	var startingStop: Stop! { return _startingStop }
	var destinationStop: Stop! { return _destinationStop }
	
}
