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
    
    func mapToSet<T:Hashable>(_ transform: (Element) -> T) -> Set<T> {
        var set = Set<T>()
        for e in self {
            set.insert(transform(e))
        }
        return set
    }
    
//    func flatMapToSet<T:Hashable, C:Collection>(_ transform: (Element) -> C) -> Set<T> where C.Iterator.Element.Type == T.Type {
//        var set = Set<T>()
//        for e in self {
//            for t in transform(e) {
//                set.insert(t)
//            }
//        }
//        return set
//        
//    }
//    
    
}
