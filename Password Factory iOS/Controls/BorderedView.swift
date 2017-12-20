//
//  BorderedView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/19/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable
class BorderedView: UIView {
    @IBInspectable var topBorder: Bool = false
    @IBInspectable var rightBorder: Bool = false
    @IBInspectable var bottomBorder: Bool = false
    @IBInspectable var leftBorder: Bool = false
    @IBInspectable var borderColor: UIColor?
    public override func layoutSubviews() {
        super.layoutSubviews()
        setDisplay()
    }
    override func prepareForInterfaceBuilder() {
        setDisplay()
    }
    func setDisplay() {
        var sides = UIRectEdge()
        if topBorder { sides.insert(.top) }
        if rightBorder { sides.insert(.right) }
        if bottomBorder { sides.insert(.bottom) }
        if leftBorder { sides.insert(.left) }
        addBorder(sides, color: borderColor ?? PFConstants.containerBorderColor)
    }
}
