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

    func setDisplay() {
        Utilities.roundCorners(view: self, corners: [.topLeft, .topRight], withBorder: false)
        backgroundColor = UIColor.white.withAlphaComponent(0.75)
    }

}
