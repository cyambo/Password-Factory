//
//  SelectTypeCollectionViewCell.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class SelectTypeCollectionViewCell: UICollectionViewCell {
    var selectType = PickerTypes.CaseType
    var typeLabel = UILabel.init()
    var imageView = UIImageView.init()
    let c = PFConstants.instance
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    func setIndex(index : Int, andType:PickerTypes) {
        selectType = andType
        var title = ""
        switch selectType {
        case .CaseType:
            title = c.caseTypes[c.getCaseType(by: UInt(index))] ?? ""
            imageView.image = TypeIcons().getCaseTypeIcon(type: c.getCaseType(by: UInt(index)))
        case .SeparatorType:
            title = c.separatorTypes[c.getSeparatorType(by: UInt(index))] ?? ""
        case .PasswordType:
            title = "PASSWORD"
        }
        typeLabel.text = title
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
        backgroundColor = UIColor.gray

    }
}
