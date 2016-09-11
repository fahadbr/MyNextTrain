//
//  CollectionExtensions.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

extension Collection {
    
    typealias Element = Self.Iterator.Element
    
    func dictionary<Key: Hashable>(keyExtractor: (Element) -> Key) -> [Key : Element] {
    
        var dict = [Key : Element]()
        for element in self {
            dict[keyExtractor(element)] = element
        }
        return dict
    }
    
    func groupBy<Key: Hashable>(keyExtractor: (Element) -> Key) -> [Key : [Element]] {
        var dict = [Key : [Element]]()
        
        for element in self {
            let k = keyExtractor(element)
            if dict[k]?.append(element) == nil {
                dict[k] = [element]
            }
        }
        return dict
    }
    
    
}
