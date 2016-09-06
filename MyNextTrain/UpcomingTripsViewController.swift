//
//  UpcomingTripsViewController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "upcomingTripsId"
fileprivate let formatter: DateFormatter = {
    $0.dateFormat = "hh:mm:ss a"
    return $0
}(DateFormatter())

class UpcomingTripsViewController: UIViewController {
    
    lazy var queryService = AppDelegate.queryService
    
    fileprivate let tableView = UITableView()
    fileprivate lazy var currentDate: Date = self.queryService.currentDate
    fileprivate var tripSummaries: [TripSummary]!
    
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
        let deerPark = StopImpl()
        deerPark.name = "Deer Park"
        deerPark.id = 72
        
//        let destination = StopImpl()
//        destination.name = "Atlantic Terminal"
//        destination.id = 12
        
        let destination = StopImpl()
        destination.name = "Penn Station"
        destination.id = 8
        currentDate = queryService.currentDate
        tripSummaries = queryService.tripSummaries(from: deerPark, to: destination, forDate: currentDate)
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
        let departing = currentDate.addingTimeInterval(summary.startingStop.departureTime)
        let arriving = currentDate.addingTimeInterval(summary.destinationStop.arrivalTime)
        
        let timeDiff = summary.destinationStop.arrivalTime - summary.startingStop.departureTime
        cell.textLabel?.text = "\(formatter.string(from: departing)) - \(formatter.string(from: arriving)) \(timeDiff.timeRepresentation)"
        
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
