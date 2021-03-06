//
//  AppThemeController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/10/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit


fileprivate struct AppTheme {
    
    struct Color {
        static var defaultText = UIColor.black
        static var defaultHighlightedText = UIColor.lightGray
        static var defaultBackground = UIColor.white
        static var altText = UIColor.darkGray
    }
    
}

extension UIButton {
    
    public static func withDefaults() -> UIButton {
        let b = UIButton()
        b.setTitleColor(UIColor.defaultText, for: .normal)
        b.setTitleColor(UIColor.defaultHighlightedText, for: .highlighted)
        return b
    }
    
}

extension UIColor {
    
    public static var defaultText: UIColor {
        return AppTheme.Color.defaultText
    }
    
    public static var defaultHighlightedText: UIColor {
        return AppTheme.Color.defaultHighlightedText
    }
    
    public static var defaultBackground: UIColor {
        return AppTheme.Color.defaultBackground
    }
    
    public static var altText: UIColor {
        return AppTheme.Color.altText
    }
    
}
