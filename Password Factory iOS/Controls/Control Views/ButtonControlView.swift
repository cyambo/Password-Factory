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
        controlButton.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
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
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        controlButton.isEnabled = enabled
    }
    @objc func pressedButton() {
        if defaultsKey == nil { return }
        if let ak = showAlertKey {
            guard let pvc = parentViewController else { return }
            Utilities.showAlert(delegate: self, alertKey: ak, parentViewController: pvc, disableAlertHiding: disableAlertHiding, onlyContinue: false, source: controlButton)
        } else {
            canContinueWithAction(canContinue: true)
        }
    }
    override func canContinueWithAction(canContinue: Bool) {
        guard let key = defaultsKey else { return }
        if canContinue {
            delegate?.controlChanged(controlButton, defaultsKey: key)
        }
    }
}
