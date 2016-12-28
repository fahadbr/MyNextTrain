//
//  Errors.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/25/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

public enum AppError: Error, CustomStringConvertible {

    case noDataFound(FavoritePairTrips)
    case generic(String)

    public var description: String {
        switch self {
        case let .noDataFound(favoritePairTrips):
            return "Do data was found for \(favoritePairTrips.date)"
        case let .generic(msg):
            return msg
        }
    }

}
