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

class ColorPickerViewController: PopupViewController {
    weak var delegate: ColorPickerViewControllerDelegate?
    var pickerColor: UIColor!
    var pickerTitle = ""
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var picker: SwiftHSVColorPicker!
    

    func setColor(_ color: UIColor, andTitle title: String) {
        pickerTitle = title
        if pickerTitle.last == "s" {
            pickerTitle = "\(pickerTitle.dropLast()) Color"
        }
        pickerTitle = "Select \(pickerTitle)"
        pickerColor = color
    }
    override func done() {
        super.done()
        if let c = picker?.color {
            delegate?.selectedColor(c)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        super.viewWillLayoutSubviews()
        titleLabel.text = pickerTitle
        picker.setViewColor(pickerColor)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        okButton.addBorder([.top,.left],color: PFConstants.tintColor)
        cancelButton.addBorder([.top],color: PFConstants.tintColor)
    }

}
