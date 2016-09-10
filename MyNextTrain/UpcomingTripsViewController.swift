//
//  UpcomingTripsViewController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "upcomingTripsId"

class UpcomingTripsViewController: UIViewController {
	
    
    lazy var queryService = AppDelegate.queryService
	
	private let pairing: StopPairing
    fileprivate let tableView = UITableView()
	fileprivate var currentDate: Date!
    fileprivate var tripSummaries: [TripSummary]!
	
	init(pairing:StopPairing) {
		self.pairing = pairing
		super.init(nibName: nil, bundle: nil)
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    override func viewDidLoad() {
		
        reloadSourceData()
		
        view.add(subView: tableView, with: Anchor.standardAnchors)
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTableView),
                                               name: GTFSFileLoader.doneLoadingFiles,
                                               object: GTFSFileLoader.instance)
        
    }
    
    func reloadSourceData() {
//        let deerPark = StopImpl()
//        deerPark.name = "Deer Park"
//        deerPark.id = 72
//        
////        let destination = StopImpl()
////        destination.name = "Atlantic Terminal"
////        destination.id = 12
//        
//        let destination = StopImpl()
//        destination.name = "Penn Station"
//        destination.id = 8
        currentDate = queryService.currentDate
        tripSummaries = queryService.tripSummaries(for: pairing, on: currentDate)
    }
    
    func reloadTableView() {
        reloadSourceData()
        tableView.reloadData()
    }
    
}

extension UpcomingTripsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        let summary = tripSummaries[indexPath.row]

        cell.textLabel?.text = summary.scheduleDescription(for: currentDate)
        
        let currentTime = Date().timeIntervalSince(currentDate)
        let subTitle:String
        switch currentTime {
        case 0..<summary.startingStop.departureTime:
            subTitle = "Departing in " + (summary.startingStop.departureTime - currentTime).timeRepresentation
        case summary.startingStop.departureTime..<summary.destinationStop.arrivalTime:
            subTitle = "Arriving in " + (summary.destinationStop.arrivalTime - currentTime).timeRepresentation
        default:
            subTitle = "Arrived"
        }
        
        cell.detailTextLabel?.text = subTitle
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripSummaries.count
    }
    
}
