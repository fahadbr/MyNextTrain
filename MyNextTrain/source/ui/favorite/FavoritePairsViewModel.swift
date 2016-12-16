//
//  FavoritePairingViewModel.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxSwift

class FavoritePairsViewModel {

    lazy var queryService = AppDelegate.queryService
    lazy var updateService = AppDelegate.updateService

    let favoritePairs: Variable<[StopPairing]>
    private let disposeBag = DisposeBag()

    init() {
        favoritePairs = Variable([])
//        DispatchQueue.global(qos: .background).async {
            self.favoritePairs.value = self.queryService.favoritePairings
//        }
    }

    func addPairing(pairing: StopPairing) {
//        DispatchQueue.global(qos: .background).async {
            do {
                try self.updateService.addFavoritePairing(from: pairing.startingStop, to: pairing.destinationStop)
            } catch let error {
                Logger.error("error updating pairing", error: error)
            }
            var pairs = self.favoritePairs.value
            pairs.append(pairing)
            self.favoritePairs.value = pairs
//        }
    }

    func removePairing(pairing: StopPairing) {

    }


}
