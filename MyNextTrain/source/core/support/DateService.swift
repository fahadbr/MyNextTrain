//
//  DateService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RxSwift

class DateService {
    static let instance = DateService(AppStateProvider.instance)

    private typealias This = DateService

    private static let formatter: DateFormatter = {
        $0.dateFormat = "ddMMyy"
        return $0
    }(DateFormatter())


    private let disposeBag = DisposeBag()
    private let _currentDate: Variable<Date>

    var currentDate: Observable<Date> {
        return _currentDate
            .asDriver()
            .distinctUntilChanged()
            .asObservable()
    }

    init(_ appStateProvider: AppStateProvider) {
        _currentDate = Variable(This.getDate())

        appStateProvider.becameActive.drive(onNext: { [weak self] _ in
            self?._currentDate.value = This.getDate()
        }).addDisposableTo(disposeBag)

    }


    private static func getDate() -> Date {
        guard let dateNoTime = This.formatter.date(from: This.formatter.string(from: Date())) else {
            //		guard let dateNoTime = formatter.date(from: "020916") else {
            Logger.error("couldn't truncate time from current date object")
            return Date()
        }
        return dateNoTime
    }





}
