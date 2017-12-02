//
//  ControlsContainer.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable
class ControlsContainer: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10.0
        self.layer.backgroundColor = UIColor.white.cgColor
        
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
