//
//  ZoomButton.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable
class ZoomButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setBackgroundImage(StyleKit.imageOfZoom(), for: .normal)
        setTitle("", for: .normal)
    }

}
