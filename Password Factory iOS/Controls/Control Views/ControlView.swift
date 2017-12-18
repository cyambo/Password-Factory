//
//  ControlView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Class that all the control views inherit from, will do all the housekeeping that needs to be done for the control views
@IBDesignable
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
        
    }
    func addViews() {
        removeSubviewsAndConstraints()
    }
    func setupView() {
        addBottomBorderWithColor(color: Utilities.cellBorderColor, width: 0.5)
        setLabel()
    }
    func setLabel() {
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.font = Utilities.labelFont
        controlLabel.text = label
    }
}
