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
    let colorWellView = UIView.init()
    override func addViews() {
        super.addViews()
        addSubview(controlLabel)
        addSubview(wellView)
        wellView.addSubview(colorWellView)
        colorWellView.isUserInteractionEnabled = false
    }
    override func setupView() {
        super.setupView()
        let views = ["label" : controlLabel, "well" : wellView]
        addVFLConstraints(constraints: ["H:|-[label(==200)]-8-[well]-|","V:|-[well]-|"], views: views)
        centerViewVertically(controlLabel)
        wellView.fillViewInContainer(colorWellView, margins: 8)
        setFromDefaults()
        
        wellView.addTarget(self, action: #selector(loadColorPicker), for: .touchUpInside)
    }
    
    /// Color selector view delegate method, called when color changed
    ///
    /// - Parameter color: selected color
    func selectedColor(_ color: UIColor) {
        setWellColor(color)
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
            vc.modalPresentationStyle = .popover
            if let pop = vc.popoverPresentationController {
                pop.permittedArrowDirections = .any
                pop.sourceView = wellView
                pop.sourceRect = wellView.bounds
                pop.delegate = vc
                _ = vc.view
                let pb = vc.picker.bounds
                let b = CGRect(x: 0, y: 0, width: pb.size.width + 14, height: pb.size.height + 14)
                vc.preferredContentSize = b.size
                vc.view.bounds = b            
            }
            
            vc.delegate = self
            vc.setColor(colorWellView.backgroundColor ?? UIColor.blue, andTitle: label ?? "")
            parentViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    /// Sets the color of the well from defaults
    func setFromDefaults() {
        guard let dk = defaultsKey else {
            return
        }
        wellView.roundCorners()
        colorWellView.roundCorners(withBorder: true, andRadius: 5)
        let color = ColorUtilities.color(fromHexString: d.string(forKey: dk)) ?? UIColor.blue
        setWellColor(color)
    }
    func setWellColor(_ color : UIColor) {
        colorWellView.backgroundColor = color
        wellView.backgroundColor = color.withAlphaComponent(0.3)
    }
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        wellView.isEnabled = enabled
    }
}
