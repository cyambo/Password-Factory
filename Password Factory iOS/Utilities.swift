//
//  Utilities.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    public class func roundCorners(layer: CALayer, withBorder: Bool) {
        layer.cornerRadius = 10.0
        layer.backgroundColor = UIColor.white.cgColor
        layer.masksToBounds = true
        if(withBorder) {
            addBorder(layer: layer)
        }
    }
    public class func roundCorners(view: UIView, corners: UIRectCorner, withBorder: Bool) {
        view.layer.backgroundColor = UIColor.white.cgColor
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 10.0, height: 10.0))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
        if(withBorder) {
            addBorder(layer: view.layer)
        }
    }
    public class func addBorder(layer: CALayer) {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.5
    }
    public class func dropShadow(view: UIView) {
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: -10, height: 10)
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }
    public class func highlightPassword(password: String, font: UIFont) ->NSAttributedString {
        
        if(DefaultsManager.get().bool(forKey: "colorPasswordText")) {
            //color it
            return Utilities.highlightPasswordString(password: password, font: font)
        } else {
            //don't color it
            return Utilities.getNonHighlightedString(s: password, font: font)
        }
    }
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
    public class func getNonHighlightedString(s: String, font: UIFont) ->NSAttributedString {
        let h = NSMutableAttributedString.init(string: s)
        let attrs = [
            NSAttributedStringKey.foregroundColor:ColorUtilities.getDefaultsColor("defaultTextColor") as Any,
            NSAttributedStringKey.font: font
        ]
        h.setAttributes(attrs, range: NSMakeRange(0, s.count))
        return h
    }
    public class func fillViewInContainer(_ view: UIView, superView: UIView, padding: Int = 0) {
        let views = ["sub" : view]
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraintString = ":|-\(padding)-[sub]-\(padding)-|"
        let hc = NSLayoutConstraint.constraints(withVisualFormat: "H\(constraintString)", options: [], metrics: nil, views: views)
        let vc = NSLayoutConstraint.constraints(withVisualFormat: "V\(constraintString)", options: [], metrics: nil, views: views)
        superView.addConstraints(hc)
        superView.addConstraints(vc)
    }
}
