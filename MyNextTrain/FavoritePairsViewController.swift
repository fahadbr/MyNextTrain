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
    lazy var updateService = AppDelegate.updateService
	
	private let tableView = UITableView()
	private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
	
	fileprivate var favoritePairings = [FavoritePairModel]()
	fileprivate var currentDate: Date!
	private var reloadSource: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
		addButton.target = self
		addButton.action = #selector(showAddFavoriteVC)
        title = "Favorite Pairs"
		
		navigationItem.rightBarButtonItem = addButton
		
		view.add(subView: tableView, with: Anchor.standardAnchors)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = 60

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadData()
	}
	
	func reloadSourceData() {
		if reloadSource {
			currentDate = queryService.currentDate
			favoritePairings = queryService.favoritePairings.map { FavoritePairModel(stopPairing: $0) }
			reloadSource = false
		}
	}
	
	func reloadData() {
		reloadSourceData()
		tableView.reloadData()
	}
	
	func showAddFavoriteVC() {
        present(UINavigationController(rootViewController: AddPairingViewController()), animated: true, completion: nil)
		reloadSource = true
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
		
		let favoritePairing = favoritePairings[indexPath.row]
		let pairing = favoritePairing.stopPairing
		cell.textLabel?.text = "\(pairing.startingStop.name) -> \(pairing.destinationStop.name)"
		
		if let nextTripSummary = favoritePairing.tripSummary ?? queryService.nextTripSummary(forPairing: pairing) {
			cell.detailTextLabel?.text = nextTripSummary.scheduleDescription(for: currentDate)
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return favoritePairings.count
	}
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try updateService.remove(pairing: favoritePairings[indexPath.row].stopPairing)
                reloadSourceData()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch let err {
                Logger.error("could not add favorite pairing", error: err)
            }
        }
    }
    

}

//MARK: - UITableViewDelegate
extension FavoritePairsViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
		let pairing = favoritePairings[indexPath.row]
		let vc = UpcomingTripsViewController(pairing: pairing.stopPairing)
		navigationController!.pushViewController(vc, animated: true)
	}
	
}


class FavoritePairModel {
	
	var stopPairing: StopPairing
	var tripSummary: TripSummary?
	
	init(stopPairing: StopPairing) {
		self.stopPairing = stopPairing
	}
	
}
