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
    fileprivate var stops: [[Stop]] = []
    fileprivate var sectionNames = [String]()
	
	fileprivate var startingStop: Stop?
	fileprivate var destinationStop: Stop?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Select From Station"
        let stopDict = queryService.allStops.groupBy(keyExtractor: { $0.name.capitalized.characters.first ?? " " as Character })
        for u in ("A" as UnicodeScalar)...("Z" as UnicodeScalar) {
            let c = Character(u)
            if let stopsForChar = stopDict[c] {
                self.stops.append(stopsForChar)
                self.sectionNames.append(String(c))
            }
        }
		
		view.add(subView: tableView, anchor: Anchor.standardAnchors)
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
		return stops.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
			?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		cell.textLabel?.text = stops[indexPath.section][indexPath.row].name
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stops[section].count
	}
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionNames
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
	
}

//MARK: - UITableViewDelegate
extension AddPairingViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        
		let selectedStop = stops[indexPath.section][indexPath.row]
		
		if startingStop == nil {
			startingStop = selectedStop
            title = "Select To Station (From \(selectedStop.name))"
		} else if destinationStop == nil {
			destinationStop = selectedStop
			createNewPairing()
		}
		
	}
	
}
