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
        subviews.forEach({
            if !($0 is UILayoutSupport) {
                $0.removeSubviews()
                $0.removeFromSuperview()
            }
        })
    }
    /// Removes constraints from subviews
    func removeConstraintsOnSubviews() {
        subviews.forEach({
            $0.removeConstraints($0.constraints)
        })
    }
    /// Removes subviews and constraints from view
    func removeSubviewsAndConstraints() {
        subviews.forEach({
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
    func addBorder(_ sides: UIRectEdge, color: UIColor = UIColor.gray, width: CGFloat = 0.5) {

        var borders = [CGRect]()
        if sides.contains(.top) {
            borders.append(CGRect(x:0,y: 0, width: frame.size.width, height:width))
        }
        if sides.contains(.right) {
            borders.append(CGRect(x: frame.size.width - width,y: 0, width:width, height: frame.size.height))
        }
        if sides.contains(.bottom) {
            borders.append(CGRect(x:0, y: frame.size.height - width, width: frame.size.width, height:width))
        }
        if sides.contains(.left) {
            borders.append(CGRect(x:0, y:0, width:width, height: frame.size.height))
        }
        for b in borders {
            let border = CALayer()
            layer.masksToBounds = true
            border.backgroundColor = color.cgColor
            border.frame = b
            layer.addSublayer(border)
        }
        //TODO: need to fix when view updates and adds borders, the old ones stay
    }

    func addGradient(_ topColor: UIColor = UIColor(white: 1, alpha: 1), _ bottomColor: UIColor = UIColor(white: 0.98, alpha: 1)) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        layer.insertSublayer(gradient, at: 0)
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
    func addBorder(_ width: CGFloat = 0.5, color : UIColor = UIColor.gray) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
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
