//
//  RealmStopService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/24/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

/**
 @dip.register StopService
 */
class RealmStopService: StopService {


    let stops: Observable<[Stop]>
    let favoritePairs: Observable<([StopPairing], ChangeSet?)>

    init() {
        let realm = try! Realm.gtfs()
        stops = Observable.changesetFrom(realm.objects(StopImpl.self)).map {
            $0.0.toArray() as [Stop]

            }.shareReplay(1)
        favoritePairs = Observable.changesetFrom(realm.objects(StopPairingImpl.self)).map {
            ($0.0.toArray() as [StopPairing], $0.1)
            }.shareReplay(1)
    }

    func addPair(from fromStop: Stop, to toStop: Stop) throws {
        let startTime = CFAbsoluteTimeGetCurrent()

        let desc = "\(fromStop.name) - \(toStop.name)"
        Logger.debug("starting to add pair \(desc)")

        let realm = try Realm.gtfs()


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
            throw AppError.generic("require type StopPairingImpl in order to delete")
        }

        let debugMessage = "deleted pair [\(pair.fromStop.name) - \(pair.toStop.name)]"

        let realm = try Realm.gtfs()

        try realm.write {
            realm.delete(realmObj)
        }
        
        Logger.debug(debugMessage)
    }
    
}
