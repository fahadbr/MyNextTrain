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
    
    func remove(pairing: StopPairing) throws {
        guard let realmObj = pairing as? StopPairingImpl else {
            throw ErrorDTO(description: "require type StopPairingImpl in order to delete")
        }
        
        //need this before deleting because otherwise it will print "invalid object" if we get description after deleting
        let debugMessage = "deleted pairing [\(pairing.description)]"
        
        let realm = try Realm()
        try realm.write {
            realm.delete(realmObj)
        }
        
        Logger.debug(debugMessage)
    }
    
    func performMigrationIfNeeded() {
        let newSchemaVersion: UInt64 = 2
        let config = Realm.Configuration(schemaVersion: newSchemaVersion, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < newSchemaVersion) {
                Logger.debug("migrating to new realm schema")
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    func setUpObjectLinks() {
        guard AppDelegate.overrideReload else { return }
        
        do {
            let realm = try Realm()
            for route in realm.allObjects(ofType: RouteImpl.self) {
                do {
                    Logger.debug("linking stops for route \(route.longName)")
                    let trips = realm.allObjects(ofType: TripImpl.self).filter(using: "routeId == %@", route.id)
                
                    let tripIds: [String] = trips.map { $0.id }
                    let stopTimes = realm.allObjects(ofType: StopTimeImpl.self).filter(using: "tripId IN %@", tripIds)
                    let stopIds = Set<Int>(stopTimes.map { $0.stopId })
                    let stops = realm.allObjects(ofType: StopImpl.self).filter(using: "id IN %@", stopIds)
                    
                    try realm.write {
                        route.stops.append(objectsIn: stops)
                    }
                    
                } catch let e {
                    Logger.error("error with deriving transfer data for route \(route.longName)", error: e)
                }
                
            }
        } catch let err {
            Logger.error("error with deriving transfer data", error: err)
        }
        
    }

}
