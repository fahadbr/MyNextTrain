//
//  AppState.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import Foundation

/**
 @dip.register AppState
 @dip.constructor init()
 */
public class AppState {

    static let resignedActiveName = Notification.Name.UIApplicationWillResignActive
    static let becameActiveName = Notification.Name.UIApplicationDidBecomeActive

    let resignedActive = NotificationCenter.default.rx.notification(resignedActiveName)

    let becameActive = NotificationCenter.default.rx.notification(becameActiveName)
    
}
