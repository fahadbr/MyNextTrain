//
//  RealmUpdateService.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RealmSwift

class RealmUpdateService: UpdateService {
	
	func addFavoritePairing(from startingStop: Stop, to destinationStop: Stop) throws {
		
		guard let startObj = startingStop as? StopImpl, let destObj = destinationStop as? StopImpl else {
			throw ErrorDTO(description: "require type StopPairingImpl in order to persist")
		}
		
		let realmObj = StopPairingImpl()
		realmObj._startingStop = startObj
		realmObj._destinationStop = destObj
		
		let realm = try Realm()
		
		try realm.write {
			realm.add(realmObj)
		}
		
		Logger.debug("added pairing [\(realmObj.description)]")
	}
}
