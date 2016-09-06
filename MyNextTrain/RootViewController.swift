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
    
    
    lazy var upcomingTripsVc:UpcomingTripsViewController = UpcomingTripsViewController()
    lazy var tripsNavController:UINavigationController = UINavigationController(rootViewController: self.upcomingTripsVc)

    override func viewDidLoad() {
        super.viewDidLoad()
		
        view.add(subView: tripsNavController.view, with: Anchor.standardAnchors)
        addChildViewController(tripsNavController)
        tripsNavController.didMove(toParentViewController: self)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

