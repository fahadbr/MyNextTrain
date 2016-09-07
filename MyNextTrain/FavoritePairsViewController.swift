//
//  FavoritePairsViewController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "FavoritePairsViewController"

class FavoritePairsViewController: UIViewController {
	
	lazy var queryService = AppDelegate.queryService
	
	private let tableView = UITableView()
	private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
	
	fileprivate var favoritePairings = [StopPairing]()
	fileprivate var currentDate: Date!

    override func viewDidLoad() {
        super.viewDidLoad()
		addButton.target = self
		addButton.action = #selector(showAddFavoriteVC)
		
		navigationItem.rightBarButtonItem = addButton
		
		view.add(subView: tableView, with: Anchor.standardAnchors)
		tableView.dataSource = self
		tableView.delegate = self

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadData()
	}
	
	func reloadSourceData() {
		currentDate = queryService.currentDate
		favoritePairings = queryService.favoritePairings
	}
	
	func reloadData() {
		reloadSourceData()
		tableView.reloadData()
	}
	
	func showAddFavoriteVC() {
		present(AddPairingViewController(), animated: true, completion: nil)
	}
	

}

//MARK: - UITableViewDataSource
extension FavoritePairsViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
			?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		let pairing = favoritePairings[indexPath.row]
		cell.textLabel?.text = "\(pairing.startingStop.name) -> \(pairing.destinationStop.name)"
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return favoritePairings.count
	}

}

//MARK: - UITableViewDelegate
extension FavoritePairsViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let pairing = favoritePairings[indexPath.row]
		let vc = UpcomingTripsViewController(pairing: pairing)
		navigationController!.pushViewController(vc, animated: true)
	}
	
}
