//
//  AppContainer.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/18/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import Dip


class AppContainer {

    static let overrideReloadReference = (name: "OVERRIDE_RELOAD", value: 12)
    static var overrideReload: Bool {
        return UserDefaults.standard.integer(forKey: overrideReloadReference.name) != overrideReloadReference.value
    }

}


public func measure<T>(_ actionName:String, _ block: () -> T ) -> T{
    let startTime = CFAbsoluteTimeGetCurrent()
    let value = block()
    Logger.debug("took \(CFAbsoluteTimeGetCurrent() - startTime) to perform \(actionName)")
    return value
}
