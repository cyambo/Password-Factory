//
//  ColorPickerView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker
protocol ColorPickerViewControllerDelegate: class {
    func selectedColor(_ color: UIColor)
}

class ColorPickerViewController: UIViewController {
    weak var delegate: ColorPickerViewControllerDelegate?
    var pickerColor: UIColor!
    var pickerTitle = ""
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var picker: SwiftHSVColorPicker!
    
    func setColor(_ color: UIColor, andTitle title: String) {
        pickerTitle = title
        if pickerTitle.last == "s" {
            pickerTitle = "\(pickerTitle.dropLast()) Color"
        }
        pickerTitle = "Select \(pickerTitle)"
        pickerColor = color
    }
    @IBAction func pressedDone(_ sender: Any) {
        if let c = picker?.color {
            delegate?.selectedColor(c)
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func pressedCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel.text = pickerTitle
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = PFConstants.tintColor
        picker.setViewColor(pickerColor)

    }
    override func viewDidLayoutSubviews() {
        container.roundCorners()
        container.dropShadow()
        titleLabel.roundCorners(corners: [.topLeft, .topRight])

        rightButton.addTopBorderWithColor(color: PFConstants.tintColor, width: 0.5)
        leftButton.addTopBorderWithColor(color: PFConstants.tintColor, width: 0.5)
        rightButton.addLeftBorderWithColor(color: PFConstants.tintColor, width: 0.5)
    }



}
