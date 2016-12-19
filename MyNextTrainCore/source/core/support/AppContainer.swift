//
//  AppContainer.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/18/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

public class AppContainer {

    static let queryService: QueryService = RealmQueryService()
	public static let updateService: UpdateService = RealmUpdateService()
    static let stopService: StopService = RealmStopService()!

    static let overrideReloadReference = (name: "OVERRIDE_RELOAD", value: 11)
    static var overrideReload: Bool {
        return UserDefaults.standard.integer(forKey: overrideReloadReference.name) != overrideReloadReference.value
    }
}
