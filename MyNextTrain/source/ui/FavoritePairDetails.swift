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

    let tripSummaries: Driver<[TripSummaryViewModel]>

    let fromStopName: Driver<String>
    let toStopName: Driver<String>

    let indexOfNext: Driver<Int?>

    init(favoritePairTrips: FavoritePairTrips, currentTimeStream: Driver<Date>) {
        self.vFavoritePairTrips = Variable(favoritePairTrips)
        let favoritePairTripsDriver = vFavoritePairTrips.asDriver()


        self.fromStopName = favoritePairTripsDriver.map({ $0.stopPairing.fromStop.name })
        self.toStopName = favoritePairTripsDriver.map({ $0.stopPairing.toStop.name })
        self.indexOfNext = favoritePairTripsDriver.flatMapLatest({ fpt -> Driver<Int?> in
            currentTimeStream.startWith(Date())
                .flatMapLatest { _ in
                    fpt.trips.map({
                        $0.indexOfNext
                    }).asDriver(onErrorJustReturn: nil)
            }
        }).distinctUntilChanged({ (v1, v2) -> Bool in (v1 ?? 0) == (v2 ?? 0) })

        self.tripSummaries = indexOfNext.startWith(nil)
            .flatMapLatest({ (index) -> Driver<[TripSummaryViewModel]> in
                favoritePairTripsDriver.flatMapLatest({
                    $0.trips.map({ trips -> [TripSummaryViewModel] in
                        trips.enumerated().map { TripSummaryViewModel($0.1, index != nil && index! == $0.0) }
                    }).asDriver(onErrorJustReturn: [])
                })
            })

        

    }

    func `switch`() {
        let favoritePairTrips = vFavoritePairTrips.value
        vFavoritePairTrips.value = favoritePairTrips.with(pairing: favoritePairTrips.stopPairing.switched)
    }


    class TripSummaryViewModel {

        let tripSummary: TripSummary
        let isNext: Bool

        init(_ tripSummary: TripSummary, _ isNext: Bool) {
            self.tripSummary = tripSummary
            self.isNext = isNext
        }

        var title: NSAttributedString {
            return tripSummary.scheduleDescription
        }
        var details: String {
            return tripSummary.upcomingEventDescription
        }

    }

    
}
