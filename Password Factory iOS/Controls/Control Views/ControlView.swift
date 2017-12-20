//
//  ControlView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Class that all the control views inherit from, will do all the housekeeping that needs to be done for the control views

class ControlView: UIView {
    @IBInspectable public var label: String? //label to display
    @IBInspectable public var defaultsKey: String? //defaults key to use
    let d = DefaultsManager.get()!
    let c = PFConstants.instance
    let controlLabel = UILabel.init() //label of the view

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeControls()
        addViews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        initializeControls()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    func initializeControls() {
        layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        d.setBool(false, forKey: "activeControl")
        d.setObject(nil, forKey: "currentControlKey")
    }
    func addViews() {
        removeSubviewsAndConstraints()
    }
    func setupView() {
        addBorder([.bottom],color: PFConstants.cellBorderColor)
        addGradient()
        setLabel()
    }

    func setLabel() {
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.font = PFConstants.labelFont
        controlLabel.text = label
    }
    func setActions(_ control: UIControl) {
        control.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        control.addTarget(self, action: #selector(touchUp(_:)), for: .touchUpInside)
        control.addTarget(self, action: #selector(touchUp(_:)), for: .touchUpOutside)
    }
    func startAction() {
        d.setBool(true, forKey: "activeControl")
        d.setObject(defaultsKey ?? "", forKey: "currentControlKey")
    }
    func endAction() {
        d.setBool(false, forKey: "activeControl")
        d.setObject("", forKey: "currentControlKey")
    }
    @objc func touchDown(_ sender: UISlider) {
        startAction()
    }
    @objc func touchUp(_ sender: UISlider) {
        endAction()
    }
}
