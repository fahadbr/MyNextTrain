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

/// A view model for a single saved pair
class FavoritePair {

    let stopPairing: StopPairing! // writing a comment hear for testing sake
    private var dateTripsTuple: Variable<(Date, [TripSummary])>
    private let nextTripSummary: Variable<TripSummary?>
    private let disposeBag = DisposeBag()


    let pairingNameText: String
    let tripDetailsText = Variable<NSAttributedString>(NSAttributedString(string: " loading.."))

    init(pairing: StopPairing,
         queryService: QueryService,
         dateService: DateService,
         appState: AppState) {
        stopPairing = pairing
        pairingNameText = "\(pairing.fromStop.name) -> \(pairing.toStop.name)"

        nextTripSummary = Variable(nil)
        dateTripsTuple = Variable(dateService.currentDate, [])

        dateService.currentDateStream
            .asObservable().distinctUntilChanged()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] date in
                self?.dateTripsTuple.value = (date, queryService.tripSummaries(for: pairing, on: date))
            }).addDisposableTo(disposeBag)

        dateTripsTuple.asObservable().subscribe(onNext: { [weak self] dateTripsPair in
            self?.setNextTripSummary(dateTripsTuple: dateTripsPair)
        }).addDisposableTo(disposeBag)

        appState.becameActive.subscribe(onNext: { [weak self] (notification) in
            guard let tuple = self?.dateTripsTuple.value else { return }
            self?.setNextTripSummary(dateTripsTuple: tuple)
        }).addDisposableTo(disposeBag)

        nextTripSummary.asObservable().subscribe(onNext: { [weak self, thisDate = self.dateTripsTuple.value.0] tripSummary in
            let isCurrentDay = thisDate == dateService.currentDate
            guard let summary = tripSummary else {
                //only try to get trips for the next day if we didnt find trips for current day
                guard isCurrentDay else {
                    self?.tripDetailsText.value = AttributedStringBuilder().append(text: "No Upcoming Trips Found", color: UIColor.altText).build
                    return
                }

                let nextDate = thisDate + (3600 * 24)
                DispatchQueue.global(qos: .background).async {
                    self?.dateTripsTuple.value = (nextDate, queryService.tripSummaries(for: pairing, on: nextDate))
                }
                return
            }

            let details = summary.scheduleDescription(for: thisDate)
            self?.tripDetailsText.value = AttributedStringBuilder()
                .append(text: isCurrentDay ? "" : "Tomorrow at")
                .append(details).build

        }).addDisposableTo(disposeBag)


    }

    private func setNextTripSummary(dateTripsTuple: (Date, [TripSummary])) {
        let currentTimeInterval = Date().timeIntervalSince(dateTripsTuple.0)
        //if the existing next trip's departure time is still valid, dont bother updating
        if (nextTripSummary.value?.departureTime ?? -1) > currentTimeInterval {
            return
        }
        let summary = dateTripsTuple.1.first(where: { $0.departureTime > currentTimeInterval })
        nextTripSummary.value = summary
    }




}
