//
//  FavoritePairContainer
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm
import MyNextTrainCore

/**
 @dip.register
 @dip.factory viewModel
 @dip.scope Singleton
 */
class FavoritePairContainer {

    var stopService: StopService

    let favoritePairs: Variable<[FavoritePairSummary]> = Variable([])
    private let disposeBag = DisposeBag()


    /**@dip.designated*/
    init(stopService: StopService,
         tripService: TripService,
         dateService: DateService,
         appState: AppState) {

        self.stopService = stopService

        let pairFunction  = { (p: StopPairing) -> FavoritePairSummary in
            FavoritePairSummary(pairing: StopPairingDTO(p),
                                tripService: tripService,
                                dateService: dateService,
                                appState: appState)
        }

        stopService.favoritePairs.bindNext { [favoritePairs = self.favoritePairs] (pairings, changeset) in
            guard let changes = changeset else {
                favoritePairs.value = pairings.map(pairFunction)
                return
            }

            // FIXME:
            // this would totally screw up if there were ever
            // inserts and deletes in the same changeset
            for i in changes.inserted {
                favoritePairs.value.insert(pairFunction(pairings[i]), at: i)
            }
            for i in changes.deleted.sorted(by: >) {
                favoritePairs.value.remove(at: i)
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
