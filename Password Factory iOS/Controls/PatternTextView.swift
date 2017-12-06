//
//  PatternTextView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable
class PatternTextView: UITextView {
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setDisplay()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDisplay()
    }
    func setDisplay() {
        Utilities.roundCorners(layer: self.layer, withBorder: true)
        textContainer.lineBreakMode = .byCharWrapping
    }

}
