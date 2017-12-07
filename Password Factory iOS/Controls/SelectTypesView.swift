//
//  SelectTypesView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class SelectTypesView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBInspectable var selectType: String?
    @IBInspectable var passwordTypeInt: Int
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    let typeLabel = UILabel.init()
    var currentSelectType = PickerTypes.CaseType
    var currentPasswordType = PFPasswordType.pronounceableType
    var collection:UICollectionView?
    required init?(coder aDecoder: NSCoder) {
        passwordTypeInt = 403
        super.init(coder: aDecoder)
        removeSubviewsAndConstraints()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = 8.0
        layout.itemSize = CGSize.init(width: 70, height: 50)
        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        guard let col = collection else{
            return
        }
        col.register(SelectTypeCollectionViewCell.self, forCellWithReuseIdentifier: "SelectTypeCell")
        col.backgroundColor = UIColor.white
        col.dataSource = self
        col.delegate = self
        addSubview(typeLabel)
        addSubview(col)
        typeLabel.text = ""
        
        let views = ["collection" : col as UIView, "label" : typeLabel as UIView]
        translatesAutoresizingMaskIntoConstraints = false
        col.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        let hc = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views)
        let hc2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[collection]-|", options: [], metrics: nil, views: views)
        let vc = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[label(==20)]-8-[collection]-8-|", options: [], metrics: nil, views: views)

        addConstraints(hc)
        addConstraints(hc2)
        addConstraints(vc)
        
    }
    func scrollToSelected() {
        if let index = d?.integer(forKey: getDefaultsKey()) {
            collection?.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
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
            return c.caseTypes.count
        case .SeparatorType:
            return c.separatorTypes.count
        case .PasswordType:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTypeCell", for: indexPath) as! SelectTypeCollectionViewCell
        cell.backgroundColor = tintColor
        cell.setIndex(index: indexPath.row, andType: currentSelectType, andPasswordType: currentPasswordType)

//        Utilities.roundCorners(layer: cell.layer, withBorder: true)
        return cell
    }

}
