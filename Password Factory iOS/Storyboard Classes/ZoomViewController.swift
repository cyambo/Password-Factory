//
//  ZoomViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/29/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class ZoomViewController: UIViewController {
    

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var zoomedPassword: UITextView!
    @IBOutlet weak var containerView: UIView!
    
    var dismissGesture: UITapGestureRecognizer?
    var formattedPassword : NSMutableAttributedString?
    var password: String?
    let font = UIFont.init(name: "Menlo", size: 56)
    let bgColor = UIColor.init(white: 0.3, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        //add a dismiss gesture
        if dismissGesture == nil {
            dismissGesture = UITapGestureRecognizer(target: self, action: #selector(closeWindow))
            view.addGestureRecognizer(dismissGesture!)
        }
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
        guard let h =  Utilities.dodgeHighlightedPasswordString(password: password, font: f, backgroundColor: bgColor).mutableCopy() as? NSMutableAttributedString else {
            return CGSize.zero
        }
        let style = NSMutableParagraphStyle.init()
        style.paragraphSpacing = 10
        style.lineSpacing = 10
        h.addAttribute(.paragraphStyle, value: style, range: NSRange.init(location: 0, length: h.length))
        h.addAttribute(.kern, value: 2, range: NSRange.init(location: 0, length: h.length))
        formattedPassword = h
        return h.size()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.backgroundColor = bgColor
        view.backgroundColor = bgColor
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

    @objc func closeWindow() {
        dismiss(animated: true, completion: nil)
    }
}
