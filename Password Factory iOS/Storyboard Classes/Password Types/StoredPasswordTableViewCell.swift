//
//  StoredPasswordTableViewCell.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/19/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class StoredPasswordTableViewCell: UITableViewCell {

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var strength: UILabel!
    @IBOutlet weak var length: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        typeImage.image = nil
        password.text = ""
        strength.text = "0"
        length.text = "0"
        
    }
    func setupCell(_ p: Passwords) {
        if let pw = p.password {
            password.attributedText = Utilities.highlightPassword(password: pw, font: password.font)
        } else {
            password.text = ""
        }

        strength.text = "\(Int(p.strength * 100))"
        length.text = "\(p.length)"
        if let passwordType = PFPasswordType.init(rawValue: Int(p.type)) {
            typeImage.image = TypeIcons.getTypeIcon(type: passwordType, andColor: PFConstants.tintColor)
        } else {
            typeImage.image = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addGradient()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
