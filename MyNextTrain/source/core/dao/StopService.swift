//
//  StopService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/17/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

protocol StopService {

    var stops: Observable<[Stop]> { get }

    var favoritePairs: Observable<([StopPairing], RealmChangeset?)> { get }

    func addPair(from fromStop: Stop, to toStop: Stop) throws
    func remove(pair: StopPairing) throws
    
}

class RealmStopService: StopService {

    let stops: Observable<[Stop]>
    let favoritePairs: Observable<([StopPairing], RealmChangeset?)>

    init?() {
        do {
            let realm = try Realm()
            stops = Observable.changesetFrom(realm.objects(StopImpl.self)).map {
                $0.0.toArray() as [Stop]
            }.shareReplay(1)
            favoritePairs = Observable.changesetFrom(realm.objects(StopPairingImpl.self)).map {
                ($0.0.toArray() as [StopPairing], $0.1)
            }.shareReplay(1)
        } catch let error {
            Logger.error("failed to initialize stop service", error: error)
            stops = Observable.empty()
            favoritePairs = Observable.empty()
            return nil
        }

    }

    func addPair(from fromStop: Stop, to toStop: Stop) throws {
        let startTime = CFAbsoluteTimeGetCurrent()

        let desc = "\(fromStop.name) - \(toStop.name)"
        Logger.debug("starting to add pair \(desc)")

        let realm = try Realm()

		
		let realmObj = StopPairingImpl()
		realmObj._fromStop = realm.objects(StopImpl.self).filter("id = %@", fromStop.id).first
		realmObj._toStop = realm.objects(StopImpl.self).filter("id = %@", toStop.id).first
        
		
		try realm.write {
			realm.add(realmObj)
		}
		
		Logger.debug("took \(CFAbsoluteTimeGetCurrent() - startTime) to add pair \(desc)")
    }

    func remove(pair: StopPairing) throws {
        guard let realmObj = pair as? StopPairingImpl else {
            throw ErrorDTO(description: "require type StopPairingImpl in order to delete")
        }
        
        let debugMessage = "deleted pair [\(pair.fromStop.name) - \(pair.toStop.name)]"
        
        let realm = try Realm()
        
        try realm.write {
            realm.delete(realmObj)
        }
        
        Logger.debug(debugMessage)
    }
    
}
