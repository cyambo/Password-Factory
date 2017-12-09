//
//  ButtonsContainer.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/7/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class ButtonsContainer: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setDisplay()
    }
    public override func awakeFromNib() {
        setDisplay()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDisplay()
    }
    func setDisplay() {
        Utilities.roundCorners(view: self, corners: [.topLeft, .topRight], withBorder: false)
    }

}
