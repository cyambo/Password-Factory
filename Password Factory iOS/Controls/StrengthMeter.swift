//
//  StrengthMeter.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable
class StrengthMeter: UIView {
    var strength = 0.01
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        StyleKit.drawStrengthMeter(frame: rect, resizing: .stretch, strengthColor: getStrengthColor(), strength: CGFloat(strength), size: rect.size)
        roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
    }
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
    func updateStrength(s: Double) {
        strength = s / 100.0
        if (strength < 0.0) { strength = 0.0 }
        if (strength > 1.0) { strength = 1.0 }
        setNeedsDisplay()
    }
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

