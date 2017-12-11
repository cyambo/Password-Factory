//
//  StrengthMeter.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable

/// Strength Meter View
class StrengthMeter: UIView {
    var strength = 1.0
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        StyleKit.drawStrengthMeter(frame: rect, resizing: .stretch, strengthColor: getStrengthColor(), strength: CGFloat(strength), size: rect.size)
        Utilities.roundCorners(view: self, corners: [.bottomLeft, .bottomRight], withBorder: false)
    }
    
    /// Gets the color for the set strength
    ///
    /// - Returns: color
    func getStrengthColor() -> UIColor {
        let strengthHue = strength * 0.3;
        let sc = UIColor.init(red: 0.848, green: 0.077, blue: 0.077, alpha: 1.0)
        var hue:CGFloat = 0.0
        var saturation:CGFloat = 0.0
        var brightness:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        sc.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor.init(hue: CGFloat(strengthHue), saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    /// Update the strength, and will redraw meter
    ///
    /// - Parameter s: strength to set
    func updateStrength(s: Double) {
        strength = s / 100.0
        if (strength < 0.0) { strength = 0.0 }
        if (strength > 1.0) { strength = 1.0 }
        setNeedsDisplay()
    }
}

