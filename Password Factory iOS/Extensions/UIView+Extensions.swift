//
//  UIView+Extensions.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/18/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import Foundation

extension UIView {
    
    
    /// Adds an array of VFL constraints
    ///
    /// - Parameters:
    ///   - constraints: array of vfl constraints
    ///   - views: views dictionary
    ///   - options: NSLayoutFormatOptions
    ///   - metrics: view metrics
    func addVFLConstraints(constraints: [String], views: [String : Any], options: NSLayoutFormatOptions = [], metrics: [String : Any] = [:]) {
        translatesAutoresizingMaskIntoConstraints = false
        for (_ , view) in views {
            (view as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        }
        for c in constraints {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: c, options: options, metrics: metrics, views: views))
        }
    }
    /// Removes subviews from UIView
    func removeSubviews() {
        self.subviews.forEach({
            if !($0 is UILayoutSupport) {
                $0.removeSubviews()
                $0.removeFromSuperview()
            }
        })
    }
    /// Removes constraints from subviews
    func removeConstraintsOnSubviews() {
        self.subviews.forEach({
            $0.removeConstraints($0.constraints)
        })
    }
    /// Removes subviews and constraints from view
    func removeSubviewsAndConstraints() {
        self.subviews.forEach({
            $0.removeSubviewsAndConstraints()
            $0.removeConstraints($0.constraints)
            $0.removeFromSuperview()
        })
    }
    /// gets the parent viewController from a view
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: 0, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width,y: 0, width:width, height:self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:self.frame.size.height - width, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:0, width:width, height:self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    /// Rounds the corners of view
    ///
    /// - Parameter withBorder: add border if needed
    func roundCorners(withBorder: Bool = false) {
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        if(withBorder) {
            addBorder()
        }
    }
    /// Round specific corners of a view
    ///
    /// - Parameters:
    ///   - view: view to round corners
    ///   - corners: UIRectCorner array
    ///   - withBorder: add a border
    func roundCorners(corners: UIRectCorner, withBorder: Bool = false) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 10.0, height: 10.0))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        if(withBorder) {
            addBorder()
        }
    }
    /// adds a standard border
    func addBorder() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.5
    }
    /// Adds a drop shadow
    func dropShadow() {
        clipsToBounds = false
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: -10, height: 10)
        layer.shadowRadius = 10
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    /// Fills view in a superview
    ///
    /// - Parameters:
    ///   - view: view to fill container with
    ///   - margins: any margins around the view
    func fillViewInContainer(_ view: UIView, margins: Int = 0) {
        let views = ["sub" : view]
        view.translatesAutoresizingMaskIntoConstraints = false
        addVFLConstraints(constraints: ["H:|-(margin)-[sub]-(margin)-|","V:|-(margin)-[sub]-(margin)-|"], views: views,options: [], metrics: ["margin": margins])
    }
    
    /// Centers a view vertically in view
    ///
    /// - Parameters:
    ///   - view: view to center
    func centerViewVertically(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    /// Centers a view horizontally in view
    ///
    /// - Parameters:
    ///   - view: view to center
    func centerViewHorizontally(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    /// Makes the attributes of two views equal
    ///
    /// - Parameters:
    ///   - firstView: first view
    ///   - secondView: second view
    ///   - attribute: NSLayoutAttribute to make equal
    func equalAttributesTo(_ firstView: UIView, _ secondView: UIView, attribute: NSLayoutAttribute) {
        addConstraint(NSLayoutConstraint.init(item: firstView, attribute: attribute, relatedBy: .equal, toItem: secondView, attribute: attribute, multiplier: 1, constant: 1))
    }
}
