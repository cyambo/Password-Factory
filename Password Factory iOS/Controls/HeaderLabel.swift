//
//  HeaderLabel.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/31/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

@IBDesignable
class HeaderLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    func initializeView() {
        font = UIFont.systemFont(ofSize: 12, weight: .light)
        textColor = UIColor.gray
        backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        
    }
    func setupView() {
        text = text?.uppercased()
        addBorder([.bottom],color: PFConstants.cellBorderColor)
    }
    override func drawText(in rect: CGRect) {
        let sideMargin = Utilities.getSideMarginsForControls()
        let insets = UIEdgeInsets.init(top: 16, left: sideMargin, bottom: 4, right: sideMargin)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
