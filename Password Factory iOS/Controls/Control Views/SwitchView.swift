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

    var touchGesture: UITapGestureRecognizer? //tap gesture recognizer that fills the view and toggles the switch
    let controlSwitch = UISwitch.init()

    override func initializeControls() {
        super.initializeControls()
        isUserInteractionEnabled = true
        touchGesture = UITapGestureRecognizer.init(target: self, action: #selector(touched))
        if (touchGesture != nil) {
            addGestureRecognizer(touchGesture!)
        }
    }

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
            controlSwitch.setOn((d.bool(forKey: key)), animated: false)
            controlSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
        }
    }
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        controlSwitch.isEnabled = enabled
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
        delegate?.controlChanged(controlSwitch, defaultsKey: key)
    }
    override func canContinueWithAction(canContinue: Bool) {
        if canContinue {
            switchChanged()
        } else {
            controlSwitch.isOn = !controlSwitch.isOn
        }
    }
    /// Called when the view is tapped
    ///
    /// - Parameter recognizer: default
    @objc func touched(recognizer : UITapGestureRecognizer) {
        controlSwitch.setOn(!controlSwitch.isOn, animated: true)
        changeSwitch()
    }
}
