//
//  AppThemeController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/10/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class AppThemeController {
    
    static let instance = AppThemeController()
    

    
    func setUpAppearanceDelegates() {
        
        
        
    }
    
    
}

fileprivate struct AppTheme {
    
    struct Color {
        static var defaultText = UIColor.black
        static var defaultHighlightedText = UIColor.lightGray
        static var defaultBackground = UIColor.white
        static var altText = UIColor.darkGray
    }
    
}

extension UIButton {
    
    static func withDefaults() -> UIButton {
        let b = UIButton()
        b.setTitleColor(UIColor.defaultText, for: .normal)
        b.setTitleColor(UIColor.defaultHighlightedText, for: .highlighted)
        return b
    }
    
}

extension UIColor {
    
    static var defaultText: UIColor {
        return AppTheme.Color.defaultText
    }
    
    static var defaultHighlightedText: UIColor {
        return AppTheme.Color.defaultHighlightedText
    }
    
    static var defaultBackground: UIColor {
        return AppTheme.Color.defaultBackground
    }
    
    static var altText: UIColor {
        return AppTheme.Color.altText
    }
    
}
