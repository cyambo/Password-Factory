//
//  ColorWellView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

//Displays a color well and shows a color picker to choose a new color
class ColorWellView: ControlView, ColorPickerViewControllerDelegate  {

    let wellView = UIButton.init()
    
    override func addViews() {
        super.addViews()
        addSubview(controlLabel)
        addSubview(wellView)
    }
    override func setupView() {
        super.setupView()
        let views = ["label" : controlLabel, "well" : wellView]
        addVFLConstraints(constraints: ["H:|-[label(==200)]-8-[well]-|","V:|-[well]-|"], views: views)
        centerViewVertically(controlLabel)
        setFromDefaults()
        wellView.addTarget(self, action: #selector(loadColorPicker), for: .touchUpInside)
    }
    
    /// Color selector view delegate method, called when color changed
    ///
    /// - Parameter color: selected color
    func selectedColor(_ color: UIColor) {
        wellView.backgroundColor = color
        if let colorString = ColorUtilities.color(toHexString: color) {
            if let key = defaultsKey {
                d.setObject(colorString, forKey: key)
                delegate?.controlChanged(nil, defaultsKey: key)
            }
        }
    }
    
    /// Loads the color picker modal
    @objc func loadColorPicker() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ColorPickerView") as? ColorPickerViewController {
            vc.modalPresentationStyle = .overCurrentContext
            
            vc.delegate = self
            vc.setColor(wellView.backgroundColor ?? UIColor.blue, andTitle: label ?? "")
            self.parentViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    /// Sets the color of the well from defaults
    func setFromDefaults() {
        guard let dk = defaultsKey else {
            return
        }
        wellView.roundCorners()
        let color = ColorUtilities.color(fromHexString: d.string(forKey: dk))
        wellView.backgroundColor = color
    }
}
