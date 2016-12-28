//
//  TodayViewController.swift
//  Widget
//
//  Created by Fahad Riaz on 12/19/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import NotificationCenter
import MyNextTrainCore
import RxCocoa
import RxSwift

class WidgetVC: UIViewController, NCWidgetProviding {

    private typealias this = WidgetVC

    private static let reuseIdentifier = "widgetReuseId"
    private let tableView = UITableView()
    private let disposeBag = DisposeBag()
    private var viewModel: WidgetViewModel!
//        = WidgetViewModel(stopService: AppContainer.stopService,
//                                                                  queryService: AppContainer.queryService,
//                                                                  dateService: DateService.instance,
//                                                                  appState: AppState.instance)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.add(subView: tableView, anchor: Anchor.standardAnchors)
        tableView.rowHeight = 50
        tableView.register(RxSubtitleCell.self, forCellReuseIdentifier: this.reuseIdentifier)
        Logger.debug("loading view")
        viewModel.tripSummaries.asDriver().drive(tableView.rx.items(cellIdentifier: this.reuseIdentifier, cellType: RxSubtitleCell.self)) {
            (index, model, cell) in
            cell.textLabel?.attributedText = model.title
            cell.detailTextLabel?.text = model.details
        }.addDisposableTo(disposeBag)
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
//        tableView.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
    
}
