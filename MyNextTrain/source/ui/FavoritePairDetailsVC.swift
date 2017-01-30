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
    private let dateService: DateService
    private var disposeBag: DisposeBag?


    /**
     @dip.designated
     @dip.arguments favoritePairTrips
     */
    init(favoritePairTrips: FavoritePairTrips, dateService: DateService) {
        self.dateService = dateService
        self.favoritePairDetails = FavoritePairDetails(favoritePairTrips: favoritePairTrips, currentTimeStream: dateService.currentTimeStream)
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

    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.disposeBag == nil else { return }

        let disposeBag = DisposeBag()

        favoritePairDetails.tripSummaries
            .drive(tableView.rx.items(cellIdentifier: reuseIdentifier, cellType: RxSubtitleCell.self)) {
                (index, model, cell) in
                cell.textLabel?.attributedText = model.title
                cell.detailTextLabel?.text = model.details
                cell.detailTextLabel?.textColor = model.isNext ? UIColor.blue : UIColor.black
            }.addDisposableTo(disposeBag)



        favoritePairDetails.indexOfNext
            .drive(onNext: { [tableView = self.tableView] _index in
                guard let index = _index else { return }

                let indexPath = IndexPath(row: index, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }).addDisposableTo(disposeBag)

        dateService.currentTimeStream
            .drive(onNext: { [tableView = self.tableView] _ in
                tableView.reloadData()
            }).addDisposableTo(disposeBag)

        self.disposeBag = disposeBag
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = nil
    }


}
