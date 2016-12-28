//
//  TripService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/24/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxSwift

public protocol TripService {

    func tripSummaries(for pairing: StopPairing, on date: Date) -> Observable<[TripSummary]>

}
