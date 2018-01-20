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
class AlertViewController: PopupViewController {
    weak var delegate: AlertViewControllerDelegate?
    
    @IBOutlet weak var hideSwitchViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertText: UILabel!
    @IBOutlet weak var hideSwitchView: SwitchView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var alertKey: String?
    var disableAlertHiding: Bool = false
    var onlyContinue: Bool = false
    let c = PFConstants.instance
    let d = DefaultsManager.get()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup hideSwitch
        hideSwitchView.autoMargins = false
        hideSwitchView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        if disableAlertHiding == true {
            hideSwitchViewHeightConstraint.constant = 0
        }
        if onlyContinue {
            cancelButton.removeFromSuperview()
            let views = ["ok" : okButton as Any]
            containerView.addVFLConstraints(constraints: ["H:|-(0)-[ok]-(0)-|"], views: views)
        }
        
        //load the alert message
        if let ak = alertKey {
            alertText.text = NSLocalizedString(ak, comment: "")
        }
        titleLabel.text = NSLocalizedString("alertTitle", comment: "Alert")
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if cancelButton != nil {
            cancelButton.addBorder([.top,.right], color: PFConstants.tintColor, width: 0.5)
        }
        okButton.addBorder([.top], color: PFConstants.tintColor, width: 0.5)
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
    override func cancel() {
        super.cancel()
        self.delegate?.canContinueWithAction(canContinue: false)
    }
    
    /// User OK'd the action
    override func done() {
        super.done()
        self.delegate?.canContinueWithAction(canContinue: true)
    }
        
    override func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        cancel()
    }
    
}
