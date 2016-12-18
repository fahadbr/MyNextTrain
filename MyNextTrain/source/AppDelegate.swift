//
//  AppDelegate.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let queryService: QueryService = RealmQueryService()
	static let updateService: UpdateService = RealmUpdateService()
    static let stopService: StopService = RealmStopService()!
    static let overrideReloadReference = (name: "OVERRIDE_RELOAD", value: 11)
    static var overrideReload: Bool {
        return UserDefaults.standard.integer(forKey: overrideReloadReference.name) != overrideReloadReference.value
    }
    
    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.updateService.performMigrationIfNeeded()
        
        GTFSFileLoader.instance.loadAllFiles()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController.instance
        window?.makeKeyAndVisible()
        return true
    }


}

