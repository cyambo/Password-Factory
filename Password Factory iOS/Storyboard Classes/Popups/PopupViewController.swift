//
//  PopupViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 1/4/18.
//  Copyright © 2018 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Class to display popovers or full screen messages
class PopupViewController: UIViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var backgroundColor: UIColor?
    var screenshot: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the background tap actions
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(recognizer:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set the background to th e screenshot if there is a background image
        if backgroundImage != nil {
            backgroundImage.image = screenshot
        }
        //set the color of the title label
        if titleLabel != nil {
            titleLabel.backgroundColor = PFConstants.tintColor
            titleLabel.textColor = UIColor.white
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //round and shadow the container view
        if containerView != nil {
            containerView.roundCorners()
            containerView.dropShadow()
        }
        //round the title label
        if titleLabel != nil {
            titleLabel.roundCorners(corners: [.topLeft, .topRight])
        }
    }
    
    /// Done method, override in subclass
    func done() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Cancel method
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    /// Gesture recognizer delegate - only accept touches outside of the container view
    ///
    /// - Parameters:
    ///   - gestureRecognizer: gesture recognizer
    ///   - touch: touches
    /// - Returns: bool for accepting touches
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if containerView != nil {
            if (touch.view?.isDescendant(of: containerView))! {
                return false
            }
        }
        return true
    }
    
    /// Cancels when background is tapped
    ///
    /// - Parameter recognizer: default recognizer
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer) {
        cancel()
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        //cancel when popover moves
        cancel()
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        //complete when popover is dismissed
        done()
    }
    
    /// Action for done or OK button
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedDone(_ sender: Any) {
        done()
    }
    
    /// Action for cancel button
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedCancel(_ sender: Any) {
        cancel()
    }


}
