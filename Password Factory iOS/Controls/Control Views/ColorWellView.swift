//
//  ColorWellView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

@IBDesignable
class ColorWellView: ControlView, ColorPickerViewControllerDelegate  {
    
    @IBInspectable public var defaultsKey: String? //defaults key to use

    let wellView = UIButton.init()
    
    override func addViews() {
        super.addViews()
        addSubview(controlLabel)
        addSubview(wellView)
    }
    override func setupView() {
        super.setupView()
        let views = ["label" : controlLabel, "well" : wellView]
        translatesAutoresizingMaskIntoConstraints = false
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        wellView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label(==200)]-8-[well]-0-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[well]-8-|", options: [], metrics: nil, views: views))
        Utilities.centerViewVerticallyInContainer(controlLabel, superview: self)
        Utilities.centerViewVerticallyInContainer(wellView, superview: self)
        setFromDefaults()
        wellView.addTarget(self, action: #selector(loadColorPicker), for: .touchUpInside)
        
    }
    func selectedColor(_ color: UIColor) {
        wellView.backgroundColor = color
        if let colorString = ColorUtilities.color(toHexString: color) {
            d.setObject(colorString, forKey: defaultsKey)
        }
    }
    @objc func loadColorPicker() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ColorPickerView") as? ColorPickerViewController {
            vc.modalPresentationStyle = .overCurrentContext
            
            vc.delegate = self
            vc.setColor(wellView.backgroundColor ?? UIColor.blue, andTitle: label ?? "")
            self.parentViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func setFromDefaults() {
        guard let dk = defaultsKey else {
            return
        }
        Utilities.roundCorners(layer: wellView.layer, withBorder: false)
        let color = ColorUtilities.color(fromHexString: d.string(forKey: dk))
        wellView.backgroundColor = color
    }
}
