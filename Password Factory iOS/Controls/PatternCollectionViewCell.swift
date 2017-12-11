//
//  PatternCollectionViewCell.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// CollectionViewCell for the pattern view - puts the pattern letter in the cell and colors it based upon pattern color
class PatternCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var patternItemText: UILabel!
    let c = PFConstants.instance
    func setPatternTypeItem(_ patternTypeItem: PFPatternTypeItem) {
        //putting the pattern letter in the cell, and highlighting it
        //based upon the pattern color
        let pc = c.patternTypeToCharacter[patternTypeItem]
        patternItemText.text = pc
        let color = ColorUtilities.patternType(toColor: patternTypeItem)
        Utilities.roundCorners(layer: layer, withBorder: false)
        patternItemText.text = pc
        patternItemText.textColor = UIColor.white
        backgroundColor = color
        
    }
}
