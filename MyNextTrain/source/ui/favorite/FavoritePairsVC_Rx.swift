//
//  FavoritePairsVC_Rx.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class FavoritePairVC : UIViewController {

    private typealias this = FavoritePairVC
    private static let reuseIdentifier = "favoritePairVCReuseId"

    private let tableView = UITableView()
    private let disposeBag = DisposeBag()

    private let favoritePairs = FavoritePairsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.add(subView: tableView, anchor: Anchor.standardAnchors)
        title = "Favorite Pairs"

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addButton
        
        addButton.rx.tap.asDriver().drive(onNext: { [weak self, favoritePairs = self.favoritePairs] _ in
            let vc = AddPairingViewController()
            vc.favoritePairs = favoritePairs
            self?.present(UINavigationController(rootViewController: vc),
                          animated: true,
                          completion: nil)
        }).addDisposableTo(disposeBag)
        
        tableView.rowHeight = 60
        tableView.register(FavoritePairCell.self, forCellReuseIdentifier: this.reuseIdentifier)

        favoritePairs.favoritePairs.asDriver().drive(tableView.rx.items(cellIdentifier: this.reuseIdentifier, cellType: FavoritePairCell.self)) {
            (index, favoritePair, cell) in
            cell.textLabel?.text = favoritePair.pairingNameText
            favoritePair.tripDetailsText.asDriver()
                .drive(cell.detailTextLabel!.rx.attributedText)
                .addDisposableTo(cell.reuseDisposeBag)
        }.addDisposableTo(disposeBag)

        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)

        tableView.rx.modelSelected(FavoritePair.self).subscribe(onNext: { [weak self] (pair) in
            let vc = UpcomingTripsViewController(pairing: pair.stopPairing)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).addDisposableTo(disposeBag)

        tableView.rx.itemDeleted.bindNext { [weak self] (indexPath) in
            self?.favoritePairs.removePairing(at: indexPath.row)
        }.addDisposableTo(disposeBag)
    }





}
