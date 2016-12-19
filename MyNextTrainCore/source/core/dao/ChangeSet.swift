//
//  ChangeSet.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/18/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RxRealm

protocol ChangeSet {
    /// the indexes in the collection that were deleted
    var deleted: [Int] { get }
    
    /// the indexes in the collection that were inserted
    var inserted: [Int] { get }
    
    /// the indexes in the collection that were modified
    var updated: [Int] { get }
}

extension RealmChangeset: ChangeSet {}
