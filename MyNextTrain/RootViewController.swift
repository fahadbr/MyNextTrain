//
//  RootViewController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    static let instance = RootViewController()
	
	
    
    lazy var favoritePairsVc:FavoritePairsViewController = FavoritePairsViewController()
    lazy var navController:UINavigationController = UINavigationController(rootViewController: self.favoritePairsVc)

    override func viewDidLoad() {
        super.viewDidLoad()
		
        view.add(subView: navController.view, anchor: Anchor.standardAnchors)
        addChildViewController(navController)
        navController.didMove(toParentViewController: self)
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

