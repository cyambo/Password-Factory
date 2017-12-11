//
//  UIView+removeSubviews.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//


extension UIView {
    
    
    /// Removes subviews from UIView
    func removeSubviews() {
        self.subviews.forEach({
            if !($0 is UILayoutSupport) {
                $0.removeSubviews()
                $0.removeFromSuperview()
            }
        })
        
    }
}
