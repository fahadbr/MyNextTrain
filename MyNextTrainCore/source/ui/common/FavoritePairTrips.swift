//
//  FavoritePairTrips.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/19/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxSwift

public class FavoritePairTrips {

    public let stopPairing: StopPairing
    public let date: Date
    private let tripService: TripService
    private let appState: AppState


    public private(set) lazy var trips: ReplaySubject<[TripSummary]> = self.createTripsVariable()
    public private(set) lazy var nextTrip: Observable<(Date, TripSummary)> = self.createNextTripObservable()


    private let disposeBag = DisposeBag()

    public init(pairing: StopPairing,
                date: Date,
                tripService: TripService,
                appState: AppState) {

        self.stopPairing = pairing
        self.date = date
        self.appState = appState
        self.tripService = tripService

    }

    /// Creates a copy object with the date set as T + 1
    public var next: FavoritePairTrips {
        return FavoritePairTrips(pairing: stopPairing,
                                 date: date.plus(days: 1),
                                 tripService: tripService,
                                 appState: appState)
    }


    /// Create a copy object with a new pairing
    ///
    /// - Parameter pairing: the pairing to use in the new object
    /// - Returns: a new object
    public func with(pairing: StopPairing) -> FavoritePairTrips {
        return FavoritePairTrips(pairing: pairing,
                                 date: date,
                                 tripService: tripService,
                                 appState: appState)
    }

    private func createTripsVariable() -> ReplaySubject<[TripSummary]> {
        let vTrips = ReplaySubject<[TripSummary]>.create(bufferSize: 1)

        tripService.tripSummaries(for: stopPairing, on: date)
            .debug("trips refresh for date \(date)", trimOutput: true)
            .subscribe(vTrips).addDisposableTo(disposeBag)
        return vTrips
    }

    private func createNextTripObservable() -> Observable<(Date, TripSummary)> {
        let becameActive = Notification(name: AppState.becameActiveName)
        return trips
            .asObservable()
            .takeLast(1)
            .flatMapLatest({ [appState = self.appState, date = self.date] (trips) -> Observable<(Date, TripSummary)> in
                return appState.becameActive.startWith(becameActive).map({ (notification) -> (Date, TripSummary) in
                    guard let next = trips.next else {
                        throw AppError.noDataFound(self)
                    }
                    return (date, next)
                })
            }).debug("next trip refresh", trimOutput: true)

    }


}
