//
//  RootViewController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import MyNextTrainCore

/**
 @dip.register
 @dip.constructor init()
 @dip.factory vc
 */
public class RootVC: UIViewController {
	
	
    /**@dip.inject*/
    var favoritePairsVc: FavoritePairsVC!
    
    private(set) lazy var navController: UINavigationController = UINavigationController(rootViewController: self.favoritePairsVc)

    override public func viewDidLoad() {
        super.viewDidLoad()
		
        view.add(subView: navController.view, anchor: Anchor.standardAnchors)
        addChildViewController(navController)
        navController.didMove(toParentViewController: self)
		
    }

}

