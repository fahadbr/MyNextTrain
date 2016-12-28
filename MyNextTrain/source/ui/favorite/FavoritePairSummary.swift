//
//  FavoritePairSummary.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/16/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MyNextTrainCore

/// A view model for a single saved pair
class FavoritePairSummary {

    let favoritePairTrips: FavoritePairTrips

    let pairingNameText: String
    private (set) var tripDetailsText: Driver<NSAttributedString>

    var stopPairing: StopPairing {
        return favoritePairTrips.stopPairing
    }

    init(pairing: StopPairing,
         tripService: TripService,
         dateService: DateService,
         appState: AppState) {

        pairingNameText = "\(pairing.fromStop.name) -> \(pairing.toStop.name)"
        tripDetailsText = Driver.never()

        let currentDate = dateService.currentDate

        favoritePairTrips = FavoritePairTrips(pairing: pairing,
                                                 date: currentDate,
                                                 tripService: tripService,
                                                 appState: appState)


        let defaultText = NSAttributedString(string: " loading..")
        tripDetailsText = favoritePairTrips.nextTrip.catchError({ [currentDayTrips = self.favoritePairTrips] _ in currentDayTrips.next.nextTrip })
            .map { (date, trip) -> NSAttributedString in
                let isCurrentDay = date == dateService.currentDate
                let details = trip.scheduleDescription
                return AttributedStringBuilder()
                    .append(text: isCurrentDay ? "" : "Tomorrow at: ")
                    .append(details).build

            }.asDriver(onErrorJustReturn: NSAttributedString(string: "No trips found for the next 24 hours"))
            .startWith(defaultText)

    }

}
