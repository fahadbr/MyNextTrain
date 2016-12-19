//
//  RootViewController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

public class RootViewController: UIViewController {
    
    public static let instance = RootViewController()
	
	
    
    lazy var favoritePairsVc: FavoritePairVC = FavoritePairVC()
    lazy var navController: UINavigationController = UINavigationController(rootViewController: self.favoritePairsVc)

    override public func viewDidLoad() {
        super.viewDidLoad()
		
        view.add(subView: navController.view, anchor: Anchor.standardAnchors)
        addChildViewController(navController)
        navController.didMove(toParentViewController: self)
		
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

