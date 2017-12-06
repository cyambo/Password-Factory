//
//  SelectTypesView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class SelectTypesView: UIView, UICollectionViewDataSource {
    
    @IBInspectable var selectType: String?
    let c = PFConstants.instance
    let typeLabel = UILabel.init()
    var selectTypeEnum :PickerTypes?
    var collection:UICollectionView?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        removeSubviewsAndConstraints()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize.init(width: 70, height: 50)
        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        guard let col = collection else{
            return
        }
        col.register(SelectTypeCollectionViewCell.self, forCellWithReuseIdentifier: "SelectTypeCell")
        col.backgroundColor = UIColor.white
        col.dataSource = self
        addSubview(typeLabel)
        addSubview(col)
        typeLabel.text = ""
        
        let views = ["collection" : col as UIView, "label" : typeLabel as UIView]
        
        col.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        let hc = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views)
        let hc2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[collection]-|", options: [], metrics: nil, views: views)
        let vc = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label(==20)]-[collection]-|", options: [], metrics: nil, views: views)

        addConstraints(hc)
        addConstraints(hc2)
        addConstraints(vc)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let selType = PickerTypes(rawValue: (selectType ?? "Case")) else {
            return
        }
        selectTypeEnum = selType
        typeLabel.text = "\(selType.rawValue) Type"
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let selType = selectTypeEnum else {
            return 0
        }
        switch selType {
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
        if let st = selectTypeEnum {
            cell.setIndex(index: indexPath.row, andType: st)
        }
        Utilities.roundCorners(layer: cell.layer, withBorder: true)
        return cell
    }

}
