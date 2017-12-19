//
//  ControlsContainer.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable

/// Container for the password controls
class ControlsContainer: UIView {



    public override func layoutSubviews() {
        super.layoutSubviews()
        setDisplay()
    }


    func setDisplay() {
        let color = PFConstants.containerBorderColor
        if let rootView = window?.rootViewController?.view {

            //do not put a top border if is aligned to the top of the window
            var sides = UIRectEdge()
            if frame.origin.y != 0 {
                sides.insert(.top)
            }
            
            //do not put a border if the bottom of the frame is at the bottom of the window
            if frame.origin.y + frame.size.height <= rootView.frame.size.height - (rootView.safeAreaInsets.bottom + rootView.safeAreaInsets.top) {
                sides.insert(.bottom)
            }
            addBorder(sides, color: color)
        }
    }
}
