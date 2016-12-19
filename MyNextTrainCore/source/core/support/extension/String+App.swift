//
//  StringExtension.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/22/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

extension String {
	
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return self[index(startIndex, offsetBy: r.lowerBound) ..< index(startIndex, offsetBy: r.upperBound)]
    }
	
}

extension UnicodeScalar: Strideable {
    
    public typealias Stride = Int32
    
    public func advanced(by n: Int32) -> UnicodeScalar {
        return UnicodeScalar(UInt32(n + Int32(self.value)))!
    }
    
    public func distance(to other: UnicodeScalar) -> Int32 {
        return Int32(self.value) - Int32(other.value)
    }
    
}
