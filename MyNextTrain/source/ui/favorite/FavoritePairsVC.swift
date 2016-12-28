//
//  FavoritePairsVC.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import MyNextTrainCore

/**
 @dip.register
 @dip.constructor init()
 @dip.factory vc
 */
class FavoritePairsVC : UIViewController {

    private typealias this = FavoritePairsVC
    private static let reuseIdentifier = "FavoritePairsVCReuseId"

    private let tableView = UITableView()
    private let disposeBag = DisposeBag()

    /**@dip.inject*/
    var favoritePairContainer: FavoritePairContainer!
    /**@dip.inject*/
    var favoritePairDetailsVCFactory: FavoritePairDetailsVCFactory!
    /**@dip.inject*/
    var addPairVCFactory: AddPairVCFactory!


    override func viewDidLoad() {
        super.viewDidLoad()
        view.add(subView: tableView, anchor: Anchor.standardAnchors)
        title = "Favorite Pairs"

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addButton
        
        addButton.rx.tap.asDriver().drive(onNext: { [weak self, factory = addPairVCFactory!] _ in
            let vc = factory.addPairVC()

            self?.present(UINavigationController(rootViewController: vc),
                          animated: true,
                          completion: nil)
        }).addDisposableTo(disposeBag)
        
        tableView.rowHeight = 60
        tableView.register(FavoritePairCell.self, forCellReuseIdentifier: this.reuseIdentifier)

        favoritePairContainer.favoritePairs.asDriver().drive(tableView.rx.items(cellIdentifier: this.reuseIdentifier, cellType: FavoritePairCell.self)) {
            (index, favoritePair, cell) in
            cell.textLabel?.text = favoritePair.pairingNameText
            favoritePair.tripDetailsText
                .drive(cell.detailTextLabel!.rx.attributedText)
                .addDisposableTo(cell.reuseDisposeBag)
        }.addDisposableTo(disposeBag)

        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)

        tableView.rx.modelSelected(FavoritePairSummary.self).subscribe(onNext: { [weak self, favoritePairDetailsVCFactory = self.favoritePairDetailsVCFactory!] (model) in
            let vc = favoritePairDetailsVCFactory.favoritePairDetailsVC(favoritePairTrips: model.favoritePairTrips)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).addDisposableTo(disposeBag)

        tableView.rx.itemDeleted.bindNext { [weak self] (indexPath) in
            self?.favoritePairContainer.removePairing(at: indexPath.row)
        }.addDisposableTo(disposeBag)
    }


}
