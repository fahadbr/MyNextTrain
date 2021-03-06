//
//  UpcomingTripsVCOld.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import MyNextTrainCore
import RxSwift
import RxCocoa

fileprivate let reuseIdentifier = "upcomingTripsId"


class UpcomingTripsVCOld: UIViewController {
	
    
    var tripService: TripService
    var dateService: DateService
	
    private let pairingVC: PairingViewController
    fileprivate let tableView = UITableView()

    private var vTripSummaries = Variable<[TripSummary]>([])
    fileprivate var tripSummaries: [TripSummary] {
        return vTripSummaries.value
    }

    fileprivate let disposeBag = DisposeBag()
    
	fileprivate var currentDate: Date!
    fileprivate var currentTime: Date!
    fileprivate var indexOfNextTrip: Int?
    
    private var timer: Timer?

   	init(pairing:StopPairing,
	     tripService: TripService,
	     dateService: DateService) {
        self.tripService = tripService
        self.dateService = dateService
		self.pairingVC = PairingViewController(pairing: pairing)
		super.init(nibName: nil, bundle: nil)
        
        self.pairingVC.delegate = self
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
		
        reloadSourceData()
        
		view.backgroundColor = UIColor.white
        view.add(subView: pairingVC.view, anchor: .left, .right)
        pairingVC.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        pairingVC.view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        addChildViewController(pairingVC)
        pairingVC.didMove(toParentViewController: self)
        
        view.add(subView: tableView, anchor: .left, .right, .bottom)
        tableView.topAnchor.constraint(equalTo: pairingVC.view.bottomAnchor).isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        
        DispatchQueue.main.async {
            self.scrollToNextTrip(animated: false)
        }
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForNotifications()
        setUpTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterForNotifications()
        invalidateTimer()
    }
    
    fileprivate func scrollToNextTrip(animated: Bool) {
        if let indexOfNextTrip = self.indexOfNextTrip {
            tableView.scrollToRow(at: IndexPath(row: indexOfNextTrip, section: 0), at: .top, animated: animated)
        }
    }
    
    //MARK: Data refreshing
    
    private func reloadSourceData() {
        currentDate = dateService.currentDate
        tripService.tripSummaries(for: pairingVC.pairing, on: currentDate)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] (tripSummaries) in
                self?.vTripSummaries.value = tripSummaries
                self?.tableView.reloadData()
                self?.scrollToNextTrip(animated: false)
            })
            .addDisposableTo(disposeBag)
        refreshTimeDetails()
    }
    
    @objc fileprivate func reloadData() {
        reloadSourceData()
        tableView.reloadData()
    }
    
    private func refreshTimeDetails() {
        currentTime = Date()
        indexOfNextTrip = tripSummaries.index(where: { $0.departureTime >= currentTime! })
    }
    
    func refreshTripDetails() {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        
        refreshTimeDetails()
        
        for indexPath in visibleIndexPaths {
            let summary = tripSummaries[indexPath.row]
            
            if summary.departureTime > currentTime!
                || summary.arrivalTime > currentTime! {
                
                guard let cell = tableView.cellForRow(at: indexPath) else { continue }
                updateDetails(of: cell, at: indexPath, with: summary)
                
            }
        }
    }
    
    
    //MARK: Notification Handling
    
    func enterBackgroundMode() {
        invalidateTimer()
    }
    
    func enterForegroundMode() {
        reloadData()
        setUpTimer()
    }
    
    private func registerForNotifications() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(enterBackgroundMode),
                                       name: NSNotification.Name.UIApplicationWillResignActive,
                                       object: UIApplication.shared)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(enterForegroundMode),
                                       name: NSNotification.Name.UIApplicationDidBecomeActive,
                                       object: UIApplication.shared)
    }
    
    private func deregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Timer
    
    private func setUpTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(refreshTripDetails),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    

    

}
//MARK: - UITableViewDataSource
extension UpcomingTripsVCOld: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        let summary = tripSummaries[indexPath.row]

        cell.textLabel?.attributedText = summary.scheduleDescription
        updateDetails(of: cell, at: indexPath, with: summary)
        
        return cell
        
    }
    
    func updateDetails(of cell: UITableViewCell, at indexPath: IndexPath, with summary: TripSummary) {
        cell.detailTextLabel?.text = summary.upcomingEventDescription
        cell.detailTextLabel?.textColor = (indexOfNextTrip ?? -1) == indexPath.row ? UIColor.blue : UIColor.black
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripSummaries.count
    }
    
}

//MARK: - UITableViewDelegate
extension UpcomingTripsVCOld: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - PairingViewControllerDelegate
extension UpcomingTripsVCOld: PairingViewControllerDelegate {
    
    func pairingDidChange() {
        reloadData()
        scrollToNextTrip(animated: false)
    }
    
}
