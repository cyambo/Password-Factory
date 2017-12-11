//
//  UIView+parentViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/10/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import Foundation
extension UIView {
    
    /// gets the parent viewController from a view
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
