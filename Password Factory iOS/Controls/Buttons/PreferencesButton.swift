//
//  PreferencesButton.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/16/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//


import UIKit
@IBDesignable

/// Preferences Button
class PreferencesButton: UIBarButtonItem {
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setDisplay()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setDisplay()
    }
    func setDisplay() {
        image = StyleKit.imageOfPreferencesButton(strokeColor: UIColor.black)
        title = ""
    }
    
}
