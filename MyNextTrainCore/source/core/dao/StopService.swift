//
//  StopService.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/17/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import RxSwift


public protocol StopService {

    var stops: Observable<[Stop]> { get }

    var favoritePairs: Observable<([StopPairing], ChangeSet?)> { get }

    func addPair(from fromStop: Stop, to toStop: Stop) throws
    func remove(pair: StopPairing) throws
    
}
