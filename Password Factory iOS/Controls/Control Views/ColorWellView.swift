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
    var currentHexColor: String?
    override func addViews() {
        super.addViews()
        addSubview(controlLabel)
        addSubview(wellView)
        wellView.addSubview(colorWellView)
        colorWellView.isUserInteractionEnabled = false
    }
    override func setupView() {
        super.setupView()
        let views = ["label" : controlLabel, "well" : wellView, "color" : colorWellView]
        addVFLConstraints(constraints: ["H:|-[label(==200)]-8-[well]-|","V:|-(12)-[well]-(12)-|"], views: views)
        addVFLConstraints(constraints: ["H:|-(8)-[color]-(8)-|","V:|-(1)-[color]-(1)-|"], views: views)
        centerViewVertically(controlLabel)
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
                delegate?.controlChanged(wellView, defaultsKey: key)
            }
        }
    }
    override func updateFromObserver(change: Any?) {
        guard let ch = change as? String else { return }
        guard let key = defaultsKey else { return }
        guard let color = ColorUtilities.color(fromHexString: ch) else { return }
        if ch != currentHexColor {
            setWellColor(color)
            delegate?.controlChanged(wellView, defaultsKey: key)
            alertChangeFromiCloud()
        }

    }
    /// Loads the color picker modal
    @objc func loadColorPicker() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let colorPickerViewController = storyboard.instantiateViewController(withIdentifier: "ColorPickerView") as? ColorPickerViewController {
            _ = colorPickerViewController.view
            let pb = colorPickerViewController.picker.bounds
            let pickerBounds = CGRect(x: 0, y: 0, width: pb.size.width + 14, height: pb.size.height + 14)
            colorPickerViewController.setColor(colorWellView.backgroundColor ?? UIColor.blue, andTitle: label ?? "")
            colorPickerViewController.delegate = self
            if let pvc = parentViewController {
                Utilities.showPopover(parentViewController: pvc, viewControllerToShow: colorPickerViewController, popoverBounds: pickerBounds, source: colorWellView)
            }
        }
    }
    
    /// Sets the color of the well from defaults
    func setFromDefaults() {
        guard let dk = defaultsKey else {
            return
        }
        wellView.roundCorners(withBorder: false, andRadius: 4)
        colorWellView.roundCorners(withBorder: false, andRadius: 4)
        let color = ColorUtilities.color(fromHexString: d.string(forKey: dk)) ?? UIColor.blue
        setWellColor(color)
    }
    func setWellColor(_ color : UIColor) {
        currentHexColor = ColorUtilities.color(toHexString: color)
        currentValue = currentHexColor
        colorWellView.backgroundColor = color
        wellView.backgroundColor = color.withAlphaComponent(0.1)
    }
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        wellView.isEnabled = enabled
    }
}
