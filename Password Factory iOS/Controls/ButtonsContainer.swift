//
//  ButtonsContainer.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/7/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Container for the bottom buttons
@IBDesignable
class ButtonsContainer: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        setDisplay()
    }
    override func prepareForInterfaceBuilder() {
        setDisplay()
    }
    func setDisplay() {
        Utilities.roundCorners(view: self, corners: [.topLeft, .topRight], withBorder: false)
    }

}
