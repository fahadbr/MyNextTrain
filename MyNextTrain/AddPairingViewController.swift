//
//  AddPairingViewController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "AddPairingViewController"

class AddPairingViewController: UIViewController {
	
	lazy var queryService = AppDelegate.queryService
	lazy var updateService = AppDelegate.updateService
	
	private let tableView = UITableView()
	fileprivate var stops = [Stop]()
	
	fileprivate var startingStop: Stop?
	fileprivate var destinationStop: Stop?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Select From Station"
		stops = queryService.allStops
		
		view.add(subView: tableView, with: Anchor.standardAnchors)
		tableView.dataSource = self
		tableView.delegate = self
		
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
	}
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
	
	fileprivate func createNewPairing() {
		assert(startingStop != nil, "startingStop was nil")
		assert(destinationStop != nil, "destinationStop was nil")
		do {
			try updateService.addFavoritePairing(from: startingStop!, to: destinationStop!)
		} catch let err {
			Logger.error("could not add favorite pairing", error: err)
		}
		dismiss(animated: true, completion: nil)
	}
	
}


//MARK: - UITableViewDataSource
extension AddPairingViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
			?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		cell.textLabel?.text = stops[indexPath.row].name
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stops.count
	}
	
}

//MARK: - UITableViewDelegate
extension AddPairingViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        
		let selectedStop = stops[indexPath.row]
		
		if startingStop == nil {
			startingStop = selectedStop
            title = "Select To Station (From \(selectedStop.name))"
		} else if destinationStop == nil {
			destinationStop = selectedStop
			createNewPairing()
		}
		
	}
	
}
