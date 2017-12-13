//
//  UIView+removeConstraintsOnSubviews.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//


extension UIView {
    
    
    /// Removes constraints from subviews
    func removeConstraintsOnSubviews() {
        self.subviews.forEach({
            $0.removeConstraints($0.constraints)
        })
    }
}
