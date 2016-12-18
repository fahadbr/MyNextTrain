//
//  RealmUpdateService.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RealmSwift

class RealmUpdateService: UpdateService {
    
    lazy var queryService = AppDelegate.queryService
	
	func addFavoritePairing(from fromStop: Stop, to toStop: Stop) throws {

        let startTime = CFAbsoluteTimeGetCurrent()

        let desc = "\(fromStop.name) - \(toStop.name)"
        Logger.debug("starting to add pairing \(desc)")

        let realm = try Realm()

		
		let realmObj = StopPairingImpl()
		realmObj._fromStop = realm.objects(StopImpl.self).filter("id = %@", fromStop.id).first
		realmObj._toStop = realm.objects(StopImpl.self).filter("id = %@", toStop.id).first
        
		
		try realm.write {
			realm.add(realmObj)
		}
		
		Logger.debug("took \(CFAbsoluteTimeGetCurrent() - startTime) to add pairing \(desc)")
	}
    
    func remove(pairing: StopPairing) throws {
        guard let realmObj = pairing as? StopPairingImpl else {
            throw ErrorDTO(description: "require type StopPairingImpl in order to delete")
        }
        
        let debugMessage = "deleted pairing [\(pairing.fromStop.name) - \(pairing.toStop.name)]"
        
        let realm = try Realm()
        
        try realm.write {
            realm.delete(realmObj)
        }
        
        Logger.debug(debugMessage)
    }
    
    func performMigrationIfNeeded() {
        let newSchemaVersion: UInt64 = 5
        let config = Realm.Configuration(schemaVersion: newSchemaVersion, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < newSchemaVersion) {
                Logger.debug("migrating to new realm schema")
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    func setUpObjectLinks() {
        guard AppDelegate.overrideReload else {
            return
        }
        
        do {
            let realm = try Realm()
            for stop in realm.objects(StopImpl.self) {
                let stopTimes = realm.objects(StopTimeImpl.self).filter("stopId == %@", stop.id)
                try realm.write {
                    stop.stopTimes.append(objectsIn: stopTimes)
                }
            }
            
            for trip in realm.objects(TripImpl.self) {
                let stopTimes = realm.objects(StopTimeImpl.self).filter("tripId == %@", trip.id)
                try realm.write {
                    trip.stopTimes.append(objectsIn: stopTimes)
                }
            }
            
        } catch let e {
            Logger.error("error setting up object links", error: e)
        }
    }
    

}

func measure<T>(_ actionName:String, _ block: () -> T ) -> T{
    let startTime = CFAbsoluteTimeGetCurrent()
    let value = block()
    Logger.debug("took \(CFAbsoluteTimeGetCurrent() - startTime) to perform \(actionName)")
    return value
}
