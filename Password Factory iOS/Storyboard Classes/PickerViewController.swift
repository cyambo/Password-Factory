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
class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    weak var delegate: PickerViewControllerDelegate?
    let c = PFConstants.instance
    var pickerType: PickerTypes?
    @IBOutlet weak var itemPickerView: UIPickerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    func setType(type: PickerTypes) {
        pickerType = type
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(recognizer:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    func setupView() {
        Utilities.roundCorners(layer: containerView.layer, withBorder: false)
        if let typeString = pickerType?.rawValue {
            self.titleLabel.text = "Select \(typeString)"
        } else {
            self.titleLabel.text = "Select"
        }
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let pt = pickerType {
            switch (pt) {
            case .CaseType:
                return c.caseTypes.count
            case .SeparatorType:
                return c.separatorTypes.count
            case .PasswordType:
                return 4
            }
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let pt = pickerType {
            switch (pt) {
            case .CaseType:
                let ct = c.getCaseType(by: UInt(row))
                return c.caseTypes[ct]
            case .SeparatorType:
                let st = c.getSeparatorType(by: UInt(row))
                return c.separatorTypes[st]
            case .PasswordType:
                return "PASSWORD TYPE"
            }
        }
        return ""

    }
    func done() {
        self.dismiss(animated: true, completion: nil)
        if let pt = pickerType {
            delegate?.selectedItem(type: pt, index: itemPickerView.selectedRow(inComponent: 0))
        }
    }
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
