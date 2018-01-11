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
class ControlView: UIView, DefaultsManagerDelegate, AlertViewControllerDelegate {

    @IBInspectable public var label: String? //label to display
    @IBInspectable public var defaultsKey: String? //defaults key to use
    @IBInspectable public var enabledKey: String? //key to observe to determine if the control is enabled or disabled
    @IBInspectable public var showAlertKey: String? //if set the control will show an alert before allowing the change to be made
    @IBInspectable public var showAlertKeyAlternate: String? //if set the control will show an alert before allowing the change to be made
    @IBInspectable public var disableAlertHiding: Bool = false //disables the ability to hide the alert
    
    @IBInspectable public var controlGroup: String? //sets the group the control belongs to
    @IBInspectable public var controlGroupIndex: Int = 0 //Index of the control group item
    @IBInspectable public var bordered: Bool = true //show the border or not
    @IBInspectable public var autoMargins: Bool = true //to use automatic margins for big screens
    @IBOutlet var delegate: ControlViewDelegate?
    static var controlGroups = [String:[Int:ControlView]]()
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
        if autoMargins {
            let sideMargin = Utilities.getSideMarginsForControls()
            layoutMargins = UIEdgeInsets(top: 8, left: sideMargin, bottom: 8, right: sideMargin)
        }
        if bordered {
            addBorder([.bottom],color: PFConstants.cellBorderColor)
        }
        setLabel()
        backgroundColor = UIColor.white
        controlLabel.adjustsFontSizeToFitWidth = true
    }
    
    /// Sets up the obeverver for an enabled key
    func setObservers() {
        if let ek = enabledKey{
            d.observeDefaults(self, keys: [ek])
            setEnabled(d.bool(forKey: ek))
        }
        if let dk = defaultsKey {
            d.observeDefaults(self, keys: [dk])
        }
    }
    func removeObservers() {
        if let ek = enabledKey{
            d.removeDefaultsObservers(self, keys: [ek])
        }
        if let dk = defaultsKey {
            d.removeDefaultsObservers(self, keys: [dk])
        }
    }
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            addToControlGroup()
            setObservers()
        } else {
            removeFromControlGroup()
            removeObservers()
        }
    }
    
    /// Called when the view appears and adds the item to a control group if set
    func addToControlGroup() {
        guard let cg = controlGroup else { return }
        if ControlView.controlGroups[cg] == nil {
            ControlView.controlGroups[cg] = [Int:ControlView]()
        }
        ControlView.controlGroups[cg]?[controlGroupIndex] = self
    }
    
    /// Removes the item from the control group
    func removeFromControlGroup() {
        guard let cg = controlGroup else { return }
        if ControlView.controlGroups[cg] != nil {
            ControlView.controlGroups[cg]?.removeValue(forKey: controlGroupIndex)
        }
    }
    
    /// Gets the controlGroupIndex for the next item
    ///
    /// - Parameter reversed: reverse the direction
    /// - Returns: controlGroupIndex of next item
    func getNextControlGroupIndex(reversed: Bool = false) -> Int? {
        guard let cg = controlGroup else { return nil }
        guard let views = ControlView.controlGroups[cg] else { return nil }
        var viewIndex = views.keys.sorted()
        if reversed {
            viewIndex = viewIndex.reversed()
        }
        var found : Int?
        for index in viewIndex {
            if !reversed {
                if index > controlGroupIndex {
                    found = index
                    break
                }
            } else {
                if index < controlGroupIndex {
                    found = index
                    break
                }
            }

        }
        //if it isn't found that means we rolled over, so get the first item
        if found == nil {
            found = viewIndex.first
        }
        return found!
    }
    
    /// Button action to go to the next item in the control group
    @objc func goToNextItemInControlGroup() {
        guard let found = getNextControlGroupIndex() else { return }
        selectControlGroupItem(found)
    }
    
    /// Button action to go to the previous item in the control group
    @objc func goToPreviousItemInControlGroup() {
        guard let found = getNextControlGroupIndex(reversed: true) else { return }
        selectControlGroupItem(found)
    }
    
    /// Called from the button action to select the item at controlGroupIndex
    ///
    /// - Parameter atIndex: controlGroupIndex to select
    private func selectControlGroupItem(_ atIndex: Int) {
        guard let cg = controlGroup else { return }
        guard let views = ControlView.controlGroups[cg] else { return }
        views[atIndex]?.selectCurrentControlGroupItem()
    }
    
    /// Called to select the current control group item - override in each of the types for specific actions
    func selectCurrentControlGroupItem() {

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
    
    /// AlertViewControllerDelegate method - called when alert is dismissed
    ///
    /// - Parameter continue: whether or not to continue with action
    func canContinueWithAction(canContinue: Bool) {
        
    }

    /// Called when a defaults key changes - DefaultsManagerDelegate method
    ///
    /// - Parameters:
    ///   - keyPath: defaults key
    ///   - change: change message
    func observeValue(_ keyPath: String?, change: [AnyHashable : Any]?) {
        guard let ch = change else {
            return
        }
        if keyPath == enabledKey {
            guard let enabled = ch["new"] as? Bool else {
                return
            }
            setEnabled(enabled)
        } else if keyPath == defaultsKey {
            updateFromObserver(change: ch["new"])
        }

    }
    func updateFromObserver(change: Any?) {
        
    }
    func alertChangeFromiCloud() {
        guard let pvc = parentViewController else { return }
        Utilities.showAlert(delegate: self, alertKey: "remoteStoreChangeAlert", parentViewController: pvc, disableAlertHiding: false, onlyContinue: true, source: controlLabel)
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
