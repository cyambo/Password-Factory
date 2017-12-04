//
//  Utilities.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    public class func roundCorners(layer: CALayer, withBorder: Bool) {
        layer.cornerRadius = 10.0
        layer.backgroundColor = UIColor.white.cgColor
        layer.masksToBounds = true
        if(withBorder) {
            layer.borderColor = UIColor.gray.cgColor
            layer.borderWidth = 0.5
        }
    }
    public class func dropShadow(layer: CALayer) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
