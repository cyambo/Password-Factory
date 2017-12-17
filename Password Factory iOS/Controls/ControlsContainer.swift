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
        let color = Utilities.containerBorderColor
        if let rootView = window?.rootViewController?.view {
            let conv = convert(frame, to: rootView)
            //do not put a top border if is aligned to the top of the window
            if conv.origin.y != 0 {
                addTopBorderWithColor(color: color, width: 0.5)
            }
            //do not put a border if the bottom of the frame is at the bottom of the window
            if(conv.origin.y + conv.size.height != rootView.frame.size.height) {
                addBottomBorderWithColor(color: color, width: 0.5)
            }
        }
    }
}
