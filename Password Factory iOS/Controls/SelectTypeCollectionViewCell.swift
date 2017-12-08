//
//  SelectTypeCollectionViewCell.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class SelectTypeCollectionViewCell: UICollectionViewCell {
    var currentSelectType = PickerTypes.CaseType
    var currentPasswordType = PFPasswordType.pronounceableType
    var typeLabel = UILabel.init()
    var imageView = UIImageView.init()
    let c = PFConstants.instance
    let d = DefaultsManager.get()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    func setIndex(index : Int, andType selectType:PickerTypes, andPasswordType passwordType: PFPasswordType) {
        currentSelectType = selectType
        currentPasswordType = passwordType
        
        var title = ""
        var selected = false
        let prefix = c.getNameFor(type: currentPasswordType)
        switch selectType {
        case .CaseType:
            title = c.caseTypes[c.getCaseType(by: UInt(index))] ?? ""
            imageView.image = TypeIcons().getCaseTypeIcon(c.getCaseType(by: UInt(index)))
            selected = (index == d?.integer(forKey: "\(prefix.lowercased())\(selectType.rawValue)TypeIndex"))
        case .SeparatorType:
            title = c.separatorTypes[c.getSeparatorType(by: UInt(index))] ?? ""
            imageView.image = TypeIcons().getSeparatorTypeIcon(c.getSeparatorType(by: UInt(index)))
            selected = (index == d?.integer(forKey: "\(prefix.lowercased())\(selectType.rawValue)TypeIndex"))
            
        case .PasswordType:
            title = "PASSWORD"
        }
        typeLabel.text = title
        if selected {
            backgroundColor = UIColor(red:0.99, green:0.31, blue:0.16, alpha:1.0)
        } else {
            backgroundColor = UIColor(red:0.99, green:0.31, blue:0.16, alpha:0.5)
        }
    }
    func setupView() {
        removeSubviews()
        Utilities.roundCorners(layer: layer, withBorder: false)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        typeLabel.font = UIFont.systemFont(ofSize: 10)
        typeLabel.textColor = UIColor.white
        addSubview(imageView)
        addSubview(typeLabel)
        typeLabel.text = "Underscore"
        typeLabel.textAlignment = .center
        let views = ["label" : typeLabel as UIView, "image" : imageView as UIView]
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let hc = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[label]-(0)-|", options: [], metrics: nil, views: views)
        let hc2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[image]-(8)-|", options: [], metrics: nil, views: views)
        let vc = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[image]-5-[label(==12)]-(5)-|", options: [], metrics: nil, views: views)
        
        addConstraints(hc)
        addConstraints(hc2)
        addConstraints(vc)
        backgroundColor = UIColor.white

    }
}
