//
//  AlertViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 1/1/18.
//  Copyright © 2018 Cristiana Yambo. All rights reserved.
//

import UIKit
protocol AlertViewControllerDelegate: class {
    
    /// Delegate method that is called to notify the delegate if the action can proceed
    ///
    /// - Parameter canContinue: true if the action can proceed
    func canContinueWithAction(canContinue: Bool)
}
class AlertViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    weak var delegate: AlertViewControllerDelegate?
    
    @IBOutlet weak var hideSwitchViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertText: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hideSwitchView: SwitchView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var alertKey: String?
    var disableAlertHiding: Bool = false
    let c = PFConstants.instance
    let d = DefaultsManager.get()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup hideSwitch
        hideSwitchView.autoMargins = false
        hideSwitchView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backgroundImage.image = Utilities.screenshot()
        titleLabel.backgroundColor = PFConstants.tintColor
        titleLabel.textColor = UIColor.white
        containerView.roundCorners()
        containerView.dropShadow()
        titleLabel.roundCorners(corners: [.topLeft, .topRight])
        cancelButton.addBorder([.top,.right], color: PFConstants.tintColor, width: 0.5)
        okButton.addBorder([.top], color: PFConstants.tintColor, width: 0.5)
        cancelButton.setTitleColor(UIColor.red, for: .normal)
        if disableAlertHiding == true {
            hideSwitchViewHeightConstraint.constant = 0
        }
        //load the alert message
        if let ak = alertKey {
            if let message = c.errorMessages[ak] {
                alertText.text = message
            }
        }
        titleLabel.text = "Alert"
    }
    
    /// Returns true if the alert is hidden, if it is it will call delegate automatically
    ///
    /// - Parameter alertKeyToShow: alertKey for the view - allows to get error message and hidden key
    /// - Returns: true if hidden
    func checkIfHidden(alertKeyToShow: String) -> Bool {
        alertKey = alertKeyToShow
        guard let hk = getHideKey() else { return false }
        hideSwitchView.defaultsKey = hk
        let hidden = d.bool(forKey: hk)
        if hidden {
            self.delegate?.canContinueWithAction(canContinue: true)
        }
        return hidden
    }
    
    /// Gets the defaults key used to hide the warning (hide[CAP]Key
    ///
    /// - Returns: hide key
    private func getHideKey() -> String? {
        guard let ak = alertKey else { return nil }
        guard let f = ak.first else { return nil }
        let firstChar = String(describing: f).uppercased()
        return "hide\(firstChar)\(ak.dropFirst())"
    }
    
    /// User cancelled the action
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedCancel(_ sender: UIButton) {
        self.delegate?.canContinueWithAction(canContinue: false)
        dismiss(animated: true, completion: nil)
    }
    
    /// User OK'd the action
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedOk(_ sender: UIButton) {
        self.delegate?.canContinueWithAction(canContinue: true)
        dismiss(animated: true, completion: nil)
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        self.delegate?.canContinueWithAction(canContinue: false)
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.delegate?.canContinueWithAction(canContinue: false)
    }
    
}
