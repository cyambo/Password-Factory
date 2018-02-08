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
        StyleKit.drawStrengthMeter(frame: rect, resizing: .stretch, strengthColor: ColorUtilities.getStrengthColor(Float(strength)), strength: CGFloat(strength))
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateStrength(s: 0.5)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setDisplay()
    }
    
    /// Update the strength, and will redraw meter
    ///
    /// - Parameter s: strength to set
    func updateStrength(s: Double) {
        
        strength = s
        if (strength < 0.0) { strength = 0.0 }
        if (strength > 1.0) { strength = 1.0 }
        setNeedsDisplay()
    }
    func setDisplay() {
        addBorder([.top,.bottom], color: PFConstants.containerBorderColor)

    }
}

