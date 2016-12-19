//
//  AppDelegate.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import RealmSwift
import MyNextTrainCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        AppContainer.updateService.performMigrationIfNeeded()
        
        GTFSFileLoader.instance.loadAllFiles()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController.instance
        window?.makeKeyAndVisible()
        return true
    }


}

