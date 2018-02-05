//
//  DeleteButton.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/16/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable

/// Delete Button
class DeleteButton: UIButton {
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setDisplay()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setDisplay()
    }
    func setDisplay() {
        setImage(StyleKit.imageOfDeleteButton(), for: .normal)
        setTitle("", for: .normal)
    }
    
}
