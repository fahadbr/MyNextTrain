//
//  AttributedStringBuilder.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/10/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class AttributedStringBuilder {
    
    private var components: [NSAttributedString] = []
    
    var build: NSAttributedString {
        let s = NSMutableAttributedString()
        components.forEach { s.append($0) }
        return s
    }
    
    @discardableResult
    func append(text: String, font: UIFont? = nil, color: UIColor? = nil) -> AttributedStringBuilder {
        
        var attributes: [String : Any] = [:]
        if let c = color {
            attributes[NSForegroundColorAttributeName] = c
        }
        
        if let f = font {
            attributes[NSFontAttributeName] = f
        }
        
        return append(NSAttributedString(string: text, attributes: attributes))
    }
    
    @discardableResult
    func append(_ attributedString: NSAttributedString) -> AttributedStringBuilder {
        components.append(attributedString)
        return self
    }
    
}
