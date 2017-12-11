//
//  BigTypeIconView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/5/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// Displays a big version of the type icon
class BigTypeIconView: UIImageView {

    
    /// Draws the type icon in the current context
    ///
    /// - Parameter type: password type to draw
    func setImage(type: PFPasswordType) {
        UIGraphicsBeginImageContext(frame.size)
        TypeIcons.drawTypeIcon(type: type, frame: frame, color: UIColor.white)
        image = UIGraphicsGetImageFromCurrentImageContext()
    }


}
