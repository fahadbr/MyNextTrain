//
//  AddPairVC.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/6/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import MyNextTrainCore

fileprivate let reuseIdentifier = "AddPairVC"

/**
 @dip.register
 @dip.scope Unique
 @dip.factory vc
 @dip.constructor init()
 */
class AddPairVC: UIViewController {
	

	
	private let tableView = UITableView()
    fileprivate var stops: [[Stop]] = []
    fileprivate var sectionNames = [String]()
	
	fileprivate var fromStop: Stop?
	fileprivate var toStop: Stop?

    /**@dip.inject*/
    var favoritePairs: FavoritePairContainer!
    /**@dip.inject*/
    var stopService: StopService!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Select From Station"

        func makeStops(stops: [Stop]) {
            let stopDict = stops.groupBy(keyExtractor: { $0.name.capitalized.characters.first ?? " " as Character })
            for u in ("A" as UnicodeScalar)...("Z" as UnicodeScalar) {
                let c = Character(u)
                if let stopsForChar = stopDict[c] {
                    self.stops.append(stopsForChar)
                    self.sectionNames.append(String(c))
                }
            }
        }

        stopService.stops
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: makeStops).dispose()

		
		view.add(subView: tableView, anchor: Anchor.standardAnchors)
		tableView.dataSource = self
		tableView.delegate = self
		
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
	}
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
	
	fileprivate func createNewPairing() {
		assert(fromStop != nil, "fromStop was nil")
		assert(toStop != nil, "toStop was nil")
        favoritePairs.addPairing(pairing: StopPairingDTO(fromStop: fromStop!, toStop: toStop!))
		dismiss(animated: true, completion: nil)
	}
	
}


//MARK: - UITableViewDataSource
extension AddPairVC: UITableViewDataSource {
	
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
extension AddPairVC: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        
		let selectedStop = stops[indexPath.section][indexPath.row]
		
		if fromStop == nil {
			fromStop = selectedStop
            title = "Select To Station (From \(selectedStop.name))"
		} else if toStop == nil {
			toStop = selectedStop
			createNewPairing()
		}
		
	}
	
}
