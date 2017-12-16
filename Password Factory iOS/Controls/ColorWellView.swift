//
//  ColorWellView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

@IBDesignable
class ColorWellView: UIView, ColorPickerViewControllerDelegate  {
    
    @IBInspectable public var defaultsKey: String? //defaults key to use
    @IBInspectable public var label: String? //label to display

    let wellView = UIButton.init()
    let controlLabel = UILabel.init()
    
    let d = DefaultsManager.get()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addViews()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    func addViews() {
        removeSubviewsAndConstraints()
        addSubview(controlLabel)
        addSubview(wellView)
    }
    func setupView() {
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
            d?.setObject(colorString, forKey: defaultsKey)
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
        controlLabel.text = label
        Utilities.roundCorners(layer: wellView.layer, withBorder: false)
        let color = ColorUtilities.color(fromHexString: d?.string(forKey: dk))
        wellView.backgroundColor = color
    }
}
