//
//  BigTypeIconView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/5/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class BigTypeIconView: UIImageView {

    override func awakeFromNib() {

    }
    func setImage(type: PFPasswordType) {
        UIGraphicsBeginImageContext(frame.size)
        TypeIcons.drawTypeIcon(type: type, frame: frame, color: UIColor.white)
        image = UIGraphicsGetImageFromCurrentImageContext()
    }


}
