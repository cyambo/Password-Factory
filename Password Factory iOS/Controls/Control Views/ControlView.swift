//
//  ControlView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Class that all the control views inherit from, will do all the housekeeping that needs to be done for the control views
@objc public protocol ControlViewDelegate: class {
    func controlChanged(_ control: UIControl?, defaultsKey: String)
}
class ControlView: UIView, DefaultsManagerDelegate {
    
    @IBInspectable public var label: String? //label to display
    @IBInspectable public var defaultsKey: String? //defaults key to use
    @IBInspectable public var enabledKey: String? //key to observe to determine if the control is enabled or disabled
    @IBInspectable public var showAlertKey: String? //if set the control will show an alert before allowing the change to be made
    @IBOutlet var delegate: ControlViewDelegate?
    
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    var isEnabled : Bool = true
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
    
    /// Initialize current control, only called from init
    func initializeControls() {
        d.setBool(false, forKey: "activeControl")
    }
    
    /// called to add views, only called from init
    func addViews() {
        removeSubviewsAndConstraints()
    }
    
    /// Sets up the view when display is ready
    func setupView() {
        let sideMargin = Utilities.getSideMarginsForControls()
        layoutMargins = UIEdgeInsets(top: 8, left: sideMargin, bottom: 8, right: sideMargin)
        addBorder([.bottom],color: PFConstants.cellBorderColor)
        setLabel()
        setEnabledObserver()
        backgroundColor = UIColor.white
    }
    
    /// Sets up the obeverver for an enabled key
    func setEnabledObserver() {
        if let ek = enabledKey{
            d.observeDefaults(self, keys: [ek])
            setEnabled(d.bool(forKey: ek))
        }
    }
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            return
        }
        if let ek = enabledKey{
            d.removeDefaultsObservers(self, keys: [ek])
        }
    }
    /// Puts the label text on the label, and sets the font
    func setLabel() {
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.font = PFConstants.labelFont
        controlLabel.text = label
    }
    
    /// Adds actions for touchUp and touchDown to determine when control is active
    ///
    /// - Parameter control: control to monitor
    func setActions(_ control: UIControl) {
        control.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        control.addTarget(self, action: #selector(touchUp(_:)), for: .touchUpInside)
        control.addTarget(self, action: #selector(touchUp(_:)), for: .touchUpOutside)
    }
    
    /// Called when a control action is started, and sets the activeControl key
    ///
    /// - Parameter sender: default sender
    func startAction(_ sender: UIControl? = nil) {
        d.setBool(true, forKey: "activeControl")
    }
    
    /// Called when a control action is started, and unsets the activeControl key
    ///
    /// - Parameter sender: default sender
    func endAction(_ sender: UIControl? = nil) {
        d.setBool(false, forKey: "activeControl")
        if let key = defaultsKey {
            delegate?.controlChanged(sender, defaultsKey: key)
        }
    }
    
    
    /// Called to enable or disable the controls
    ///
    /// - Parameter enabled: bool for enabled status
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        controlLabel.isEnabled = enabled
        if enabled {
            alpha = 1
        } else {
            alpha = 0.5
        }
    }
    
    /// Used when a defaults key changes
    ///
    /// - Parameters:
    ///   - keyPath: defaults key
    ///   - change: change message
    func observeValue(_ keyPath: String?, change: [AnyHashable : Any]?) {
        guard let ch = change else {
            return
        }
        guard let enabled = ch["new"] as? Bool else {
            return
        }
        setEnabled(enabled)
    }
    
    /// Touch Down action, calls startAction
    ///
    /// - Parameter sender: default sender
    @objc func touchDown(_ sender: UIControl) {
        startAction(sender)
    }
    
    /// Touch Up action, calls endAction
    ///
    /// - Parameter sender: default sender
    @objc func touchUp(_ sender: UIControl) {
        endAction(sender)
    }
}
