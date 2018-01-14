//
//  SwitchView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// View containing a switch and a label connected to defaults
class SwitchView: ControlView {


    let controlSwitch = UISwitch.init()

    override func addViews() {
        super.addViews()
        addSubview(controlSwitch)
        addSubview(controlLabel)
    }
    
    /// Adds and positions the switch and label
    override func setupView() {
        super.setupView()

        let views = ["switch" : controlSwitch as UIView, "label" : controlLabel as UIView]
        addVFLConstraints(constraints: ["H:|-[label]-8-[switch(==52)]-|"], views: views)
        centerViewVertically(controlLabel)
        centerViewVertically(controlSwitch)

        //sets the state and action for the switch
        if let key = defaultsKey {
            currentValue = d.bool(forKey: key)
            controlSwitch.setOn((d.bool(forKey: key)), animated: false)
            controlSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
        }
    }
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        controlSwitch.isEnabled = enabled
    }
    override func updateFromObserver(change: Any?) {
        guard let ch = change as? Bool else { return }
        if controlSwitch.isOn != ch {
            controlSwitch.isOn = ch
            changeSwitch()
            alertChangeFromiCloud()
        }

    }
    /// sets defaults for the switch state
    @objc func changeSwitch() {
        if defaultsKey == nil { return }
        if showAlertKey != nil || showAlertKeyAlternate != nil {
            guard let pvc = parentViewController else { return }
            var currentAlertKey: String?
            if showAlertKey != nil && controlSwitch.isOn {
                currentAlertKey = showAlertKey
            } else if showAlertKeyAlternate != nil && !controlSwitch.isOn {
                currentAlertKey = showAlertKeyAlternate
            }
            if let ak = currentAlertKey {
                Utilities.showAlert(delegate: self, alertKey: ak, parentViewController: pvc, disableAlertHiding: disableAlertHiding, onlyContinue: false, source: controlSwitch)
            }
            
        } else {
            switchChanged()
        }
    }
    func switchChanged() {
        guard let key = defaultsKey else { return }
        d.setBool(controlSwitch.isOn, forKey: key)
        currentValue = controlSwitch.isOn
        delegate?.controlChanged(controlSwitch, defaultsKey: key)
    }
    override func canContinueWithAction(canContinue: Bool) {
        if canContinue {
            switchChanged()
        } else {
            controlSwitch.isOn = !controlSwitch.isOn
        }
    }
}
