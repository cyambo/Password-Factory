//
//  ZoomViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/29/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class ZoomViewController: PopupViewController {
    
    @IBOutlet weak var zoomedPassword: UITextView!

    var formattedPassword : NSMutableAttributedString?
    var password: String?
    let font = UIFont.init(name: "Menlo", size: 59)

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.init(white: 0.3, alpha: 1.0)
    }

    
    /// Formats the password and highlights it
    ///
    /// - Parameter password: password to zoom
    /// - Returns: size of formatted password
    func formatPassword(password : String) -> CGSize {
        self.password = password
        guard let f = font else {
            return CGSize.zero
        }
        guard let bg = backgroundColor else { return CGSize.zero }
        guard let h =  Utilities.dodgeHighlightedPasswordString(password: password, font: f, backgroundColor: bg).mutableCopy() as? NSMutableAttributedString else {
            return CGSize.zero
        }
        let style = NSMutableParagraphStyle.init()
        style.paragraphSpacing = 10
        style.lineSpacing = 10
        style.alignment = .justified
        h.addAttribute(.paragraphStyle, value: style, range: NSRange.init(location: 0, length: h.length))
        h.addAttribute(.kern, value: 2, range: NSRange.init(location: 0, length: h.length))
        formattedPassword = h
        return h.size()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = backgroundColor
        setPasswordView()
    }
    
    /// Sets up the password view so that it scrolls and lays out properly
    func setPasswordView() {
        zoomedPassword.textContainer.lineBreakMode = .byCharWrapping
        zoomedPassword.textContainer.maximumNumberOfLines = 1
        zoomedPassword.layoutManager.allowsNonContiguousLayout = false
        zoomedPassword.attributedText = formattedPassword
        zoomedPassword.scrollRangeToVisible(NSRange.init(location: 0, length: 0))
    }

}
