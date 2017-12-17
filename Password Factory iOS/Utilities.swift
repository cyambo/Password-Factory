//
//  Utilities.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    static let tintColor = UIColor(red:0.99, green:0.28, blue:0.12, alpha:1.0)

    static let cellBorderColor = UIColor(white: 0.85, alpha: 1.0)
    static let containerBorderColor = UIColor(white: 0.6, alpha: 1.0)
    static let labelFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    /// Rounds the corners of a layer
    ///
    /// - Parameters:
    ///   - layer: layer to round corners
    ///   - withBorder: add a border
    public class func roundCorners(layer: CALayer, withBorder: Bool) {
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        if(withBorder) {
            addBorder(layer: layer)
        }
    }
    
    /// Round specific corners of a view
    ///
    /// - Parameters:
    ///   - view: view to round corners
    ///   - corners: UIRectCorner array
    ///   - withBorder: add a border
    public class func roundCorners(view: UIView, corners: UIRectCorner, withBorder: Bool) {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 10.0, height: 10.0))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
        if(withBorder) {
            addBorder(layer: view.layer)
        }
    }
    
    /// Adds a border to a layer
    ///
    /// - Parameter layer: layer to add the border to
    public class func addBorder(layer: CALayer) {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.5
    }
    
    /// Adds a drop shadow to a uiview
    ///
    /// - Parameter view: view to add a shadow to
    public class func dropShadow(view: UIView) {
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: -10, height: 10)
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }
    
    /// Highlights a password string, or returns it in the default color based upon defaults
    ///
    /// - Parameters:
    ///   - password: password to highlight
    ///   - font: font to use
    /// - Returns: attrbuted string that is highlighted with colors set in prefs
    public class func highlightPassword(password: String, font: UIFont) ->NSAttributedString {
        
        if(DefaultsManager.get().bool(forKey: "colorPasswordText")) {
            //color it
            return Utilities.highlightPasswordString(password: password, font: font)
        } else {
            //don't color it
            return Utilities.getNonHighlightedString(s: password, font: font)
        }
    }
    
    /// Highlights the password string
    ///
    /// - Parameters:
    ///   - password: password to highlight
    ///   - font: font to use
    /// - Returns: attributed string that is highlighted
    class func highlightPasswordString(password: String, font: UIFont) -> NSAttributedString {
        let highlighted = NSMutableAttributedString()
        let defaultColor = ColorUtilities.getDefaultsColor("defaultTextColor")
        for index in password.indices {
            var color = defaultColor
            let char = password[index]
            let s = String(describing:char)
            if (s.count == 1) {
                color = ColorUtilities.getPasswordTextColor(s)
            }
            let attrs = [
                NSAttributedStringKey.foregroundColor:color as Any,
                NSAttributedStringKey.font: font
            ]
            let hChar = NSAttributedString.init(string: s, attributes: attrs)
            highlighted.append(hChar)
        }
        return highlighted
    }
    
    /// Gets the non-highlighted string using the font and default color
    ///
    /// - Parameters:
    ///   - s: string to highlight
    ///   - font: font to use
    /// - Returns: attributed string in font and default color
    public class func getNonHighlightedString(s: String, font: UIFont) ->NSAttributedString {
        let h = NSMutableAttributedString.init(string: s)
        let attrs = [
            NSAttributedStringKey.foregroundColor:ColorUtilities.getDefaultsColor("defaultTextColor") as Any,
            NSAttributedStringKey.font: font
        ]
        h.setAttributes(attrs, range: NSMakeRange(0, s.count))
        return h
    }
    
    /// Fills view in a superview
    ///
    /// - Parameters:
    ///   - view: view to fill container with
    ///   - superview: superview to fil
    ///   - padding: any padding around the view
    public class func fillViewInContainer(_ view: UIView, superview: UIView, padding: Int = 0) {
        let views = ["sub" : view]
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraintString = ":|-\(padding)-[sub]-\(padding)-|"
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H\(constraintString)", options: [], metrics: nil, views: views))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V\(constraintString)", options: [], metrics: nil, views: views))

    }
    
    /// Centers a view vertically in a container
    ///
    /// - Parameters:
    ///   - view: view to center
    ///   - superview: view that it is centered in
    public class func centerViewVerticallyInContainer(_ view: UIView, superview: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        superview.translatesAutoresizingMaskIntoConstraints = false
        let views = ["view": view, "superview": superview]
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-(<=1)-[view]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views))
    }
}
