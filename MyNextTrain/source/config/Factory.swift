//
//  Factory.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/24/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import MyNextTrainCore


protocol FavoritePairDetailsVCFactory {
    func favoritePairDetailsVC(favoritePairTrips _favoritePairTrips: FavoritePairTrips) -> FavoritePairDetailsVC
}

protocol AddPairVCFactory {
    func addPairVC() -> AddPairVC
}



/**
 @dip.register
 @dip.constructor init()
 @dip.factory dipFactory
 @dip.implements AddPairVCFactory, FavoritePairDetailsVCFactory
 */
extension VcFactory: AddPairVCFactory, FavoritePairDetailsVCFactory {}






/**
 @dip.register
 @dip.constructor init()
 @dip.factory dipFactory
 */
extension ViewModelFactory {}

