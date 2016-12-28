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
    
    public func dictionary<Key: Hashable>(keyExtractor: (Element) -> Key) -> [Key : Element] {
    
        var dict = [Key : Element]()
        for element in self {
            dict[keyExtractor(element)] = element
        }
        return dict
    }
    
    public func groupBy<Key: Hashable>(keyExtractor: (Element) -> Key) -> [Key : [Element]] {
        var dict = [Key : [Element]]()
        
        for element in self {
            let k = keyExtractor(element)
            if dict[k]?.append(element) == nil {
                dict[k] = [element]
            }
        }
        return dict
    }
    
    public func mapToSet<T:Hashable>(_ transform: (Element) -> T) -> Set<T> {
        var set = Set<T>()
        for e in self {
            set.insert(transform(e))
        }
        return set
    }
    
    
}

extension Collection where Self.Iterator.Element == TripSummary {

    public var next: TripSummary? {
        let dateTime = Date()
        return first(where: { $0.departureTime > dateTime })
    }

    public var indexOfNext: Self.Index? {
        let dateTime = Date()
        return index(where: { $0.departureTime > dateTime })
    }


}
