//
//  WidgetViewModel.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/19/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import MyNextTrainCore
import RxSwift
import RxCocoa

class WidgetViewModel {

    class TripSummaryDescription {
        let title: NSAttributedString
        let details: String
        init(_ title: NSAttributedString, _ details: String) {
            self.title = title
            self.details = details
        }
    }


    let tripSummaries: Driver<ArraySlice<TripSummaryDescription>>

    private let favoritePairTrips = Variable<FavoritePairTrips?>(nil)
    private let disposeBag = DisposeBag()

    deinit {
        print("deinitializing widget view moddel")
    }

    init(stopService: StopService,
         tripService: TripService,
         dateService: DateService,
         appState: AppState) {

        stopService.favoritePairs.map { (pairings, _) -> FavoritePairTrips in
            guard let first = pairings.first else {
                throw AppError.generic("no trips available")
            }
            Logger.debug("mapping to favorite pair trips")
            let fpt = FavoritePairTrips(pairing: StopPairingDTO(first),
                                        date: dateService.currentDate,
                                        tripService: tripService,
                                        appState: appState)
            return fpt
        }.bindTo(favoritePairTrips).addDisposableTo(disposeBag)

        tripSummaries = favoritePairTrips.asObservable().debug("trip sum description", trimOutput: false)
            .flatMapLatest({ (vFpt) -> Observable<(Date, [TripSummary]?)> in
                guard let fpt = vFpt else { return Observable.empty() }
                return fpt.trips.asObservable().map({ [vDate = fpt.date](trips) -> (Date, [TripSummary]?) in
                    return (vDate, trips)
                })
            }).map({ (date, trips) -> ArraySlice<TripSummaryDescription> in
                Logger.debug("mapping to trip summary description")
                let time = Date()
                return (trips?.filter {
                        $0.departureTime > time
                    }.map {
                        TripSummaryDescription($0.scheduleDescription, $0.upcomingEventDescription)
                    }.prefix(3)) ?? []
            }).asDriver(onErrorJustReturn: [])

    }
    
}
