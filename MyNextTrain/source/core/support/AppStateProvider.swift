//
//  AppStateProvider.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import Foundation

class AppStateProvider {

    private static let resignedActiveName = Notification.Name.UIApplicationWillResignActive
    private static let becameActiveName = Notification.Name.UIApplicationDidBecomeActive

    static let instance = AppStateProvider()

    let resignedActive = NotificationCenter.default.rx.notification(resignedActiveName)
        .asDriver(onErrorJustReturn: Notification(name: resignedActiveName))


    let becameActive = NotificationCenter.default.rx.notification(becameActiveName)
        .asDriver(onErrorJustReturn: Notification(name: becameActiveName))
}
