//
//  Route.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/15/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import RealmSwift

protocol Route {
	
    var id: Int { get }
	var shortName: String { get }
	var longName: String { get }
	var type: Int { get }
	var color: String? { get }
	var textColor: String? { get }
	
}

extension Route {
    
    var uiColor: UIColor {
        if id == 11 { //hard coding Belmont for now because its a white color
            return UIColor.defaultText
        }
        
        if let hexString = color {
            return loadUIColor(from: hexString) ?? UIColor.black
        } else {
            return UIColor.black
        }
    }
    
    var textUIColor: UIColor {
        if let hexString = textColor {
            return loadUIColor(from: hexString) ?? UIColor.gray
        } else {
            return UIColor.gray
        }
    }
    
    
    
}

fileprivate var colorCache: [String : UIColor] = [:]

fileprivate func loadUIColor(from hexString: String) -> UIColor? {
    if let cachedValue = colorCache[hexString] {
        return cachedValue
    }
    
    guard let value = Int(hexString, radix: 16) else { return nil }
    
    let r = CGFloat((value & 0xFF0000) >> 16)/255.0
    let g = CGFloat((value & 0x00FF00) >> 8)/255.0
    let b = CGFloat(value & 0x0000FF)/255.0
    
    let c = UIColor(red: r, green: g, blue: b, alpha: 1.0)
    colorCache[hexString] = c
    return c
}
