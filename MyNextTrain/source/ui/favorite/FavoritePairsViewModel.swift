//
//  FavoritePairingViewModel.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

class FavoritePairsViewModel {

    lazy var stopService = AppDelegate.stopService
    lazy var queryService = AppDelegate.queryService

    let favoritePairs: Variable<[FavoritePair]>
    private let disposeBag = DisposeBag()

    init() {
        favoritePairs = Variable([])
        let pairFunction = { (p: StopPairing) -> FavoritePair in
            FavoritePair(pairing: StopPairingDTO(p),
                         queryService: AppDelegate.queryService,
                         dateService: DateService.instance,
                         appState: AppState.instance)
        }

        stopService.favoritePairs.bindNext { [weak self] (pairings, changeset) in
            guard let changes = changeset else {
                if let vm = self {
                    vm.favoritePairs.value = pairings.map(pairFunction)
                }
                return
            }
            if changes.inserted.count != 0 {
                for i in changes.inserted {
                    self?.favoritePairs.value.insert(pairFunction(pairings[i]), at: i)
                }
            }
            if changes.deleted.count != 0 {
                let deleted = changes.deleted.sorted(by: >)
                for i in deleted {
                    self?.favoritePairs.value.remove(at: i)
                }
            }
        }.addDisposableTo(disposeBag)
        

    }

    func addPairing(pairing: StopPairing) {
        do {
            try self.stopService.addPair(from: pairing.fromStop, to: pairing.toStop)
        } catch let error {
            Logger.error("error updating pairing", error: error)
        }
    }

    func removePairing(at index: Int) {
        stopService.favoritePairs.single().bindNext { (pairings, changeset) in
            do {
                try self.stopService.remove(pair: pairings[index])
            } catch let error {
                Logger.error("error removing pairing", error: error)
            }
        }.dispose()
    }


}
