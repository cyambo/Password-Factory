//
//  PasswordTextView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable

/// TextView for the password display
class PasswordTextView: UITextView {
    public override func awakeFromNib() {
        setDisplay()
    }
    override func prepareForInterfaceBuilder() {
        setDisplay()
    }
    func setDisplay() {
        Utilities.roundCorners(layer: self.layer, withBorder: true)
    }
}
