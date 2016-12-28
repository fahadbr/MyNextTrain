//
//  DateService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RxSwift

/**
 @dip.register
 */
public class DateService {

    private typealias this = DateService

    private static let formatter = DateFormatter(pattern: "ddMMyy")

    private let disposeBag = DisposeBag()
    private (set) var currentDateStream: Variable<Date>
    
    public var currentDate: Date {
        return currentDateStream.value
    }

    /**@dip.designated*/
    init(appState: AppState) {
        currentDateStream = Variable(this.getDate())

        appState.becameActive.subscribe(onNext: { [weak self] _ in
            self?.currentDateStream.value = this.getDate()
        }).addDisposableTo(disposeBag)

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
