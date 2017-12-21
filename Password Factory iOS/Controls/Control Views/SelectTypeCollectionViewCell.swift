//
//  SelectTypeCollectionViewCell.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// CollectionViewCell for SelectTypesView
class SelectTypeCollectionViewCell: UICollectionViewCell {
    var currentSelectType = PickerTypes.CaseType
    var currentPasswordType = PFPasswordType.pronounceableType
    var typeLabel = UILabel.init()
    var imageView = UIImageView.init()

    let c = PFConstants.instance
    let d = DefaultsManager.get()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    func addSubviews() {
        removeSubviewsAndConstraints()
        addSubview(imageView)
        addSubview(typeLabel)
    }
    /// Sets the cell title and image based upon index
    ///
    /// - Parameters:
    ///   - index: index to use
    ///   - selectType: current select type
    ///   - passwordType: current password type
    func setIndex(index : Int, andType selectType:PickerTypes, andPasswordType passwordType: PFPasswordType) {
        currentSelectType = selectType
        currentPasswordType = passwordType
        typeLabel.font = UIFont.systemFont(ofSize: 10)
        typeLabel.textColor = UIColor.white
        typeLabel.textAlignment = .center
        var title = ""
        var selected = false
        let prefix = c.getNameFor(type: currentPasswordType)
        switch selectType {
        case .CaseType:
            title = c.caseTypes[c.getCaseType(by: UInt(index))] ?? ""
            imageView.image = TypeIcons().getCaseTypeIcon(c.getCaseType(by: UInt(index)))
            selected = (index == d.integer(forKey: "\(prefix.lowercased())\(selectType.rawValue)TypeIndex"))
        case .SeparatorType:
            title = c.separatorTypes[c.getSeparatorType(by: UInt(index))] ?? ""
            imageView.image = TypeIcons().getSeparatorTypeIcon(c.getSeparatorType(by: UInt(index)))
            selected = (index == d.integer(forKey: "\(prefix.lowercased())\(selectType.rawValue)TypeIndex"))
        default:
            title = ""
        }
        typeLabel.text = title
        imageView.contentMode = .scaleAspectFit
        backgroundColor = PFConstants.tintColor
        if !selected {
            backgroundColor = backgroundColor?.withAlphaComponent(0.5)
        }
    }
    
    /// Adds the image and label to the view and uses vfl to position them in the view
    func setupView() {

        roundCorners()
        let views = ["label" : typeLabel as UIView, "image" : imageView as UIView]
        let constraints = ["H:|-(0)-[label]-(0)-|","V:|-(5)-[image(==23)]","V:[label(==12)]-(5)-|","H:|-(8)-[image]-(>=7)-|"]
        addVFLConstraints(constraints: constraints, views: views)
        translatesAutoresizingMaskIntoConstraints = true

    }
}
