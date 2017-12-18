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
        initializeControls()
        addViews()
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
        layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    func addViews() {
        removeSubviewsAndConstraints()
    }
    func setupView() {
        addBottomBorderWithColor(color: PFConstants.cellBorderColor, width: 0.5)
        addGradient()
        setLabel()
    }
    func addGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        let topColor = UIColor(white: 1, alpha: 1).cgColor
        let bottomColor = UIColor(white: 0.98, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        layer.insertSublayer(gradient, at: 0)
    }
    func setLabel() {
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.font = PFConstants.labelFont
        controlLabel.text = label
    }
}
