//
//  PreferencesButton.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/16/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//


import UIKit
@IBDesignable

/// Zoom Button
class PreferencesButton: UIButton {
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setDisplay()
    }
    override func awakeFromNib() {
        setDisplay()
    }
    func setDisplay() {
        super.awakeFromNib()
        setImage(StyleKit.imageOfPreferencesButton(strokeColor: UIColor.black), for: .normal)
        setTitle("", for: .normal)
    }
    
}
