//
//  UIViewExtension.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

public enum Anchor {
    public static let standardAnchors:[Anchor] = [.top, .bottom, .left, .right]
    
    case top, bottom, left, right, centerX, centerY, width, height
    
}

extension NSLayoutConstraint {
    public func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }
}

public extension UIView {

    @discardableResult
    public func add(subView:UIView, anchor anchors: Anchor...) -> [Anchor : NSLayoutConstraint] {
        return UIView.applyConstraintsToView(withAnchors: anchors, subView: subView, parentView: self)
    }
    
    @discardableResult
    public func add(subView:UIView, anchor anchors: [Anchor]) -> [Anchor : NSLayoutConstraint] {
        return UIView.applyConstraintsToView(withAnchors: anchors, subView: subView, parentView: self)
    }
    
    public func constrainWidthToHeight(multiplier:CGFloat = 1) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: multiplier).isActive = true
    }
    
    @discardableResult
    public func constrain(height:CGFloat, widthRatio multiplier:CGFloat = 1) -> [Anchor : NSLayoutConstraint]{
        translatesAutoresizingMaskIntoConstraints = false
        return [
            .height : heightAnchor.constraint(equalToConstant: height).activate(),
            .width : widthAnchor.constraint(equalTo: heightAnchor, multiplier: multiplier)
        ]
    }
    
    @discardableResult
    public func constrain(width:CGFloat, heightRatio multiplier:CGFloat = 1) -> [Anchor : NSLayoutConstraint]{
        translatesAutoresizingMaskIntoConstraints = false
        return [
            .width : widthAnchor.constraint(equalToConstant: width).activate(),
            .height : heightAnchor.constraint(equalTo: widthAnchor, multiplier: multiplier).activate()
        ]
    }
    
    @discardableResult
    public func constrain(height:CGFloat, width:CGFloat) -> [Anchor : NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        return [
            .height : heightAnchor.constraint(equalToConstant: height).activate(),
            .width : widthAnchor.constraint(equalToConstant: width).activate()
        ]
    }
    
    
    @discardableResult
    public static func applyConstraintsToView(withAnchors anchors:[Anchor], subView:UIView, parentView:UIView) -> [Anchor:NSLayoutConstraint] {
        parentView.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        var constraintDict = [Anchor:NSLayoutConstraint]()
        for anchor:Anchor in anchors{
            constraintDict[anchor] = constraintForAnchor(anchor, subView: subView, parentView: parentView).activate()
        }
        return constraintDict
    }
    public static func constraintForAnchor(_ anchor:Anchor, subView:UIView, parentView:UIView) -> NSLayoutConstraint {
        switch anchor {
        case .top:
            return subView.topAnchor.constraint(equalTo: parentView.topAnchor)
        case .bottom:
            return subView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        case .left:
            return subView.leftAnchor.constraint(equalTo: parentView.leftAnchor)
        case .right:
            return subView.rightAnchor.constraint(equalTo: parentView.rightAnchor)
        case .centerX:
            return subView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
        case .centerY:
            return subView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        case .height:
            return subView.heightAnchor.constraint(equalTo: parentView.heightAnchor)
        case .width:
            return subView.widthAnchor.constraint(equalTo: parentView.widthAnchor)
        }
        
    }
    
}
