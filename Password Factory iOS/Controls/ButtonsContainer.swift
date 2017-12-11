//
//  ButtonsContainer.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/7/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class ButtonsContainer: UIView {

    override func draw(_ rect: CGRect) {
        Utilities.roundCorners(view: self, corners: [.topLeft, .topRight], withBorder: false)
    }
}
