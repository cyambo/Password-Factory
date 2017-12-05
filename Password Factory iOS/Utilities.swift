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
    public class func dropShadow(view: UIView) {
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: -10, height: 10)
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath

    }
}
