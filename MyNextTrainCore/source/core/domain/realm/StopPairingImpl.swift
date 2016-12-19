//
//  StopPairingImpl.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RealmSwift

class StopPairingImpl: Object, StopPairing {
	
	dynamic var _fromStop: StopImpl?
	dynamic var _toStop: StopImpl?
	
	var fromStop: Stop { return _fromStop! }
	var toStop: Stop { return _toStop! }
	
}
