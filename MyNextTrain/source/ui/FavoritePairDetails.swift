//
//  FavoritePairDetails.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/25/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MyNextTrainCore

class FavoritePairDetails {

    private let vFavoritePairTrips: Variable<FavoritePairTrips>

    let tripSummaries: Driver<[TripSummary]>

    let fromStopName: Driver<String>
    let toStopName: Driver<String>

    let indexOfNext: Driver<Int?>

    init(favoritePairTrips: FavoritePairTrips) {
        self.vFavoritePairTrips = Variable(favoritePairTrips)
        let tripsDriver = vFavoritePairTrips.asDriver()
        self.tripSummaries = tripsDriver
            .flatMapLatest({ $0.trips.asDriver(onErrorJustReturn: []) })

        self.fromStopName = tripsDriver.map({ $0.stopPairing.fromStop.name })
        self.toStopName = tripsDriver.map({ $0.stopPairing.toStop.name })
        self.indexOfNext = tripSummaries.map({ $0.indexOfNext })
        

    }

    func `switch`() {
        let favoritePairTrips = vFavoritePairTrips.value
        vFavoritePairTrips.value = favoritePairTrips.with(pairing: favoritePairTrips.stopPairing.switched)
    }

    
}
