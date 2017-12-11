//
//  SelectTypesView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// View that displays a collection view containing separator, or case types
class SelectTypesView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBInspectable var selectType: String?
    @IBInspectable var passwordTypeInt: Int
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    let typeLabel = UILabel.init()
    var currentSelectType = PickerTypes.CaseType
    var currentPasswordType = PFPasswordType.pronounceableType
    var collection:UICollectionView!
    required init?(coder aDecoder: NSCoder) {
        passwordTypeInt = 403
        super.init(coder: aDecoder)
        removeSubviewsAndConstraints()
        
        //setup the collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = 8.0
        layout.itemSize = CGSize.init(width: 70, height: 50)
        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        collection.register(SelectTypeCollectionViewCell.self, forCellWithReuseIdentifier: "SelectTypeCell")
        collection.backgroundColor = UIColor.white
        collection.dataSource = self
        collection.delegate = self
        addSubview(typeLabel)
        addSubview(collection)
        typeLabel.text = ""
        
        let views = ["collection" : collection as UIView, "label" : typeLabel as UIView]
        translatesAutoresizingMaskIntoConstraints = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label]-0-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collection]-0-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label(==20)]-12-[collection(==50)]", options: [], metrics: nil, views: views))
        Utilities.roundCorners(layer: collection.layer, withBorder: false)

        
    }
    
    /// Scrolls to the currently selected item with animation
    func scrollToSelected() {
        if let index = d?.integer(forKey: getDefaultsKey()) {
            collection?.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    /// Gets the current defaults key
    ///
    /// - Returns: defaults key
    func getDefaultsKey() -> String {
        let prefix = c.getNameFor(type: currentPasswordType).lowercased()
        return "\(prefix)\(currentSelectType.rawValue)TypeIndex"
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let selType = PickerTypes(rawValue: (selectType ?? "Case")) else {
            return
        }
        currentSelectType = selType
        typeLabel.text = "\(selType.rawValue) Type"
        currentPasswordType = PFPasswordType.init(rawValue: passwordTypeInt) ?? PFPasswordType.pronounceableType
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        d?.setInteger(indexPath.row, forKey: getDefaultsKey())
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch currentSelectType {
        case .CaseType:
            if (currentPasswordType == .randomType) { //if it is random, then we don't have Title case, so do one less
                return c.caseTypes.count - 1 
            } else {
               return c.caseTypes.count
            }
        case .SeparatorType:
            return c.separatorTypes.count
        case .PasswordType:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTypeCell", for: indexPath) as! SelectTypeCollectionViewCell
        cell.setIndex(index: indexPath.row, andType: currentSelectType, andPasswordType: currentPasswordType)
        return cell
    }

}
