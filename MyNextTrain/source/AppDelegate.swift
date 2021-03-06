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
import Dip

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = try! AppContainerConfig.configureAll()
        window?.makeKeyAndVisible()
        return true
    }


}

