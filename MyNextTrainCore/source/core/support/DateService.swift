//
//  DateService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RxSwift
import RxCocoa

/**
 @dip.register
 */
public class DateService {

    private typealias this = DateService

    private static let formatter = DateFormatter(pattern: "ddMMyy")

    private let appState: AppState
    private let disposeBag = DisposeBag()

    public let currentDateStream = Variable<Date>(this.getDate())
    public private(set) lazy var currentTimeStream: Driver<Date> = self.makeTimer(interval: 1)

    public var currentDate: Date {
        return currentDateStream.value
    }

    /**@dip.designated*/
    init(appState: AppState) {
        self.appState = appState
        appState.becameActive.subscribe(onNext: { [weak self] _ in
            self?.currentDateStream.value = this.getDate()
        }).addDisposableTo(disposeBag)
    }

    public func makeTimer(interval: RxTimeInterval) -> Driver<Date> {
        let initial = Notification(name: Notification.Name.UIApplicationDidBecomeActive)
        return Observable.of(appState.becameActive, appState.resignedActive).merge()
            .asDriver(onErrorJustReturn: initial)
            .startWith(initial)
            .flatMapLatest { (noti) -> Driver<Date> in
                switch noti.name {
                case Notification.Name.UIApplicationDidBecomeActive:
                    return Driver<Int>.interval(interval).map { _ in Date() }
                default:
                    return Driver.never()
                }
        }

    }


    private static func getDate() -> Date {
        guard let dateNoTime = this.formatter.date(from: this.formatter.string(from: Date())) else {
//            		guard let dateNoTime = formatter.date(from: "241216") else {
            Logger.error("couldn't truncate time from current date object")
            return Date()
        }
        return dateNoTime
    }





}
