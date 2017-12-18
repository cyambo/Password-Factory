//
//  PickerViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
protocol PickerViewControllerDelegate: class {
    func selectedItem(type: PickerTypes, index: Int)
}

/// Displays a picker view
class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    weak var delegate: PickerViewControllerDelegate?
    let c = PFConstants.instance
    var pickerType = PickerTypes.CaseType
    var passwordType = PFPasswordType.randomType
    let d = DefaultsManager.get()
    @IBOutlet weak var itemPickerView: UIPickerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    func setType(type: PickerTypes, passwordType: PFPasswordType) {
        pickerType = type
        self.passwordType = passwordType
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(recognizer:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let key = getDefaultsKey() {
            if let selected = d?.integer(forKey: key) {
                itemPickerView.selectRow(selected, inComponent: 0, animated: false)
            }
        }
    }
    override func viewDidLayoutSubviews() {
        setupView()
    }
    /// Sets up the views to be displayed
    func setupView() {
        containerView.roundCorners()
        containerView.dropShadow()
        titleLabel.roundCorners(corners: [.topLeft, .topRight])
        doneButton.addTopBorderWithColor(color: PFConstants.tintColor, width: 0.5)
    }
    
    /// Sets the title
    func setupTitle() {
        if pickerType == .PasswordType {
            self.titleLabel.text = "Password Source"
        } else {
            self.titleLabel.text = "Select \(pickerType.rawValue)"
        }
        titleLabel.backgroundColor = PFConstants.tintColor
        titleLabel.textColor = UIColor.white
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (pickerType) {
        case .CaseType:
            if passwordType == .randomType {
                return c.caseTypes.count - 1
            }
            return c.caseTypes.count
        case .SeparatorType:
            return c.separatorTypes.count
        case .PasswordType:
            return 4
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch (pickerType) {
        case .CaseType:
            if row == 0 {
                return "No Change"
            } else {
                let ct = c.getCaseType(by: UInt(row - 1))
                return c.caseTypes[ct]
            }

        case .SeparatorType:
            let st = c.getSeparatorType(by: UInt(row))
            return c.separatorTypes[st]
        case .PasswordType:
            let pt = c.getPasswordType(by: UInt(row))
            return c.passwordTypes[pt]
        }
    }
    
    /// Called when done is pressed, or the background is tapped
    func done() {
        self.dismiss(animated: true, completion: nil)
        let selected = itemPickerView.selectedRow(inComponent: 0)
        delegate?.selectedItem(type: pickerType, index: selected)
    }
    
    /// Gets the defaults key to use
    ///
    /// - Returns: defaults key
    func getDefaultsKey() -> String? {
        var pick = pickerType.rawValue + "Type"
        if pickerType == .PasswordType {
            pick = "Source"
        }
        if let pt = c.passwordTypes[passwordType]?.lowercased() {
            return pt + pick + "Index"
        }
        return nil
    }
    
    /// Gesture recognizer delegate - only accept touches outside of the picker display
    ///
    /// - Parameters:
    ///   - gestureRecognizer: gesture recognizer
    ///   - touch: touches
    /// - Returns: bool for accepting touches
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: containerView))! {
            return false
        }
        return true
    }
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer) {
        done()
    }
    @IBAction func pressedDone(_ sender: UIButton) {
        done()
    }
    
}
