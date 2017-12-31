//
//  ButtonControlView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/31/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class ButtonControlView: ControlView {
    let controlButton = UIButton.init(type: .system)
    
    override func addViews() {
        super.addViews()
        addSubview(controlButton)
    }
    override func setupView() {
        super.setupView()
        let views = ["button" : controlButton as UIView]
        
        addVFLConstraints(constraints: ["H:|-[button]-|","V:[button(==29)]"], views: views)
        centerViewVertically(controlButton)
    }
    override func setLabel() {
        super.setLabel()
        controlButton.setTitle(label ?? "", for: .normal)
    }

}
