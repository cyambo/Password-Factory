//
//  ZoomButton.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable

/// Zoom Button
class ZoomButton: UIButton {
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setDisplay()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setDisplay()
    }
    func setDisplay() {
        setImage(StyleKit.imageOfZoom(), for: .normal)
        setTitle("", for: .normal)
    }

}
