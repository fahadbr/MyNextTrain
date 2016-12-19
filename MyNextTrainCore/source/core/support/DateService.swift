//
//  DateService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RxSwift

class DateService {
    static let instance = DateService(AppState.instance)

    private typealias This = DateService

    private static let formatter = DateFormatter(pattern: "ddMMyy")

    private let disposeBag = DisposeBag()
    private (set) var currentDateStream: Variable<Date>
    
    var currentDate: Date {
        return currentDateStream.value
    }

    init(_ appState: AppState) {
        currentDateStream = Variable(This.getDate())

        appState.becameActive.subscribe(onNext: { [weak self] _ in
            self?.currentDateStream.value = This.getDate()
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
