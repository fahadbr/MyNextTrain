//
//  FavoritePairDetailsVC.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import MyNextTrainCore
import RxSwift
import RxCocoa

fileprivate let reuseIdentifier = "favoritePairDetailsVC"

/**
 @dip.register
 @dip.scope Unique
 @dip.factory vc
 */
class FavoritePairDetailsVC: UIViewController {

	
    private let pairingVC: PairingViewController
    private let tableView = UITableView()

    private let favoritePairDetails: FavoritePairDetails
    private let disposeBag = DisposeBag()


    /**
     @dip.designated
     @dip.arguments favoritePairTrips
     */
    init(favoritePairTrips: FavoritePairTrips) {
        self.favoritePairDetails = FavoritePairDetails(favoritePairTrips: favoritePairTrips)
		self.pairingVC = PairingViewController(favoritePairDetails: favoritePairDetails)
		super.init(nibName: nil, bundle: nil)
        
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    //MARK: View life cycle
    override func viewDidLoad() {
		view.backgroundColor = UIColor.white
        view.add(subView: pairingVC.view, anchor: .left, .right)
        pairingVC.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        pairingVC.view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        addChildViewController(pairingVC)
        pairingVC.didMove(toParentViewController: self)
        
        view.add(subView: tableView, anchor: .left, .right, .bottom)
        tableView.topAnchor.constraint(equalTo: pairingVC.view.bottomAnchor).isActive = true
        tableView.rowHeight = 60
        tableView.register(RxSubtitleCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        favoritePairDetails.tripSummaries
            .drive(tableView.rx.items(cellIdentifier: reuseIdentifier, cellType: RxSubtitleCell.self)) {
                (index, model, cell) in
                cell.textLabel?.attributedText = model.scheduleDescription
                cell.detailTextLabel?.text = model.upcomingEventDescription
                cell.detailTextLabel?.textColor = UIColor.black
        }.addDisposableTo(disposeBag)


        
        favoritePairDetails.indexOfNext
            .drive(onNext: { [tableView = self.tableView] _index in
                guard let index = _index else { return }

                let indexPath = IndexPath(row: index, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                tableView.cellForRow(at: indexPath)?.detailTextLabel?.textColor = UIColor.blue
            }).addDisposableTo(disposeBag)

        
    }
    


}
