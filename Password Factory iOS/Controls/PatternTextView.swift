//
//  PatternTextView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable

/// Text view containing the pattern text
class PatternTextView: UITextView {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setDisplay()
    }
    override func prepareForInterfaceBuilder() {
        setDisplay()
    }
    func setDisplay() {
        Utilities.roundCorners(layer: self.layer, withBorder: true)
    }

}
