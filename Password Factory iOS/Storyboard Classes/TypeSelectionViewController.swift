//
//  TypeSelectionViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TypeSelectionViewController: UIViewController {
    let passwordController = PasswordController.get(false)!
    var mainStoryboard: UIStoryboard?
    var keyboardDismissGesture: UITapGestureRecognizer?
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    var currentViewController: PasswordContainerViewController?
    var nextViewController: PasswordContainerViewController?
    var selectedIndex = -1
    
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var bigType: BigTypeIconView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var typeSelectionControl: UISegmentedControl!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        setObservers()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: use defaults for random and stored
        passwordController.useStoredType = true
        passwordController.useAdvancedType = true

        typeSelectionControl.removeAllSegments()
        for i in 0 ..< passwordController.getFilteredPasswordTypes().count {
            let currType = passwordController.getPasswordType(by: UInt(i))
            let image = TypeIcons.getTypeIcon(currType)
            typeSelectionControl.insertSegment(with: image, at: i, animated: true)
        }
        if keyboardDismissGesture == nil {
            //setting a tap gesture to dismiss keyboard when tapped outside of keyboard view
            keyboardDismissGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
            keyboardDismissGesture?.cancelsTouchesInView = false
            self.view.addGestureRecognizer(keyboardDismissGesture!)
        }
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setSelectedPasswordType()
        selectType(typeSelectionControl)
        
    }
    
    /// Called when type is selected on the segmented control - animates the next one into the view
    ///
    /// - Parameter sender: default sender

    @IBAction func selectType(_ sender: UISegmentedControl) {
        let selType = c.getPasswordType(by: UInt(typeSelectionControl.selectedSegmentIndex))
        bigType.setImage(type: selType)
        
        if let selectedViewController = getViewController(selType) {
            if (selectedIndex == -1) { //at app init selectedIndex is -1, so just add the view
                self.currentViewController = selectedViewController
                setupSlide(left: selectedViewController.view, right: UIView(), fromRight: true)
                selectedIndex = typeSelectionControl.selectedSegmentIndex
                d?.setInteger(selType.rawValue, forKey: "selectedPasswordType")
            } else { //we are selecting a new type
                nextViewController = selectedViewController
                var fromRight = true
                //if the selectedIndex is less, we are coming from the left, so animate from the left
                if self.typeSelectionControl.selectedSegmentIndex < selectedIndex {
                    fromRight = false
                }
                if let currentView = self.currentViewController?.view {
                    currentView.removeFromSuperview() //remove the current view so we can re-place it for animation
                    var left = currentView
                    var right = selectedViewController.view ?? UIView()
                    if !fromRight {
                        left = selectedViewController.view ?? UIView()
                        right = currentView
                    }
                    //setup the view for sliding
                    setupSlide(left: left, right: right, fromRight: fromRight)
                    
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: { [unowned self] in
                        if (fromRight) {
                            self.sliderView.frame.origin.x = -(self.sliderView.frame.size.width / 2)
                        } else {
                            self.sliderView.frame.origin.x = 0
                        }
                    }, completion: {[unowned self] (complete) in
                        //remove the views
                        self.currentViewController?.view.removeFromSuperview()
                        self.nextViewController?.view.removeFromSuperview()
                        //set the current one to next
                        self.currentViewController = self.nextViewController
                        self.nextViewController = nil
                        //move the slider back to zero
                        self.sliderView.frame.origin.x = 0
                        //place the view in the original places
                        self.setupSlide(left: selectedViewController.view, right: UIView(), fromRight: true)
                        self.selectedIndex = self.typeSelectionControl.selectedSegmentIndex
                        self.d?.setInteger(selType.rawValue, forKey: "selectedPasswordType")
                    })
                }

            }
        }
    }
    
    /// Sets up the slider view so we can animate it (assumes sliderView is empty)
    ///
    /// - Parameters:
    ///   - left: view on the left
    ///   - right: view on the right
    ///   - fromRight: are we coming from the right or left
    func setupSlide(left : UIView, right: UIView, fromRight: Bool) {
        //add the views
        sliderView.addSubview(left)
        sliderView.addSubview(right)
        
        left.translatesAutoresizingMaskIntoConstraints = false
        right.translatesAutoresizingMaskIntoConstraints = false
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        
        //setup the constraints to place the views side by side
        let views = ["left" : left, "right" : right]
        let metrics = ["width": sliderView.frame.size.width / 2]
        
        sliderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[left(width)]-0-[right(width)]", options: [], metrics: metrics, views: views))
        sliderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[left]-0-|", options: [], metrics: metrics, views: views))
        sliderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[right]-0-|", options: [], metrics: metrics, views: views))
        //place the slider to the left or right so we can start the animation
        if !fromRight {
            sliderView.frame.origin.x = -(sliderView.frame.size.width / 2)
        } else {
            sliderView.frame.origin.x = 0
        }
    }
    /// Generates password when button is pressed
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedGenerateButton(_ sender: Any) {
        currentViewController?.generatePassword()
    }
    
    /// Copies the password to the pasteboard
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedCopyButton(_ sender: Any) {
        if let currPass = currentViewController?.passwordTextView.text {
            UIPasteboard.general.string = currPass
        }
        
    }
    
    /// selects the current password type on the segmented control
    func setSelectedPasswordType() {
        guard let typeInt = d?.integer(forKey: "selectedPasswordType") else {
            return
        }
        guard let currType = PFPasswordType.init(rawValue: typeInt) else {
            return
        }
        let index = passwordController.getIndexBy(currType)
        typeSelectionControl.selectedSegmentIndex = Int(index)
        
    }
    
    /// Gets the view controller for password type
    ///
    /// - Parameter passwordType: password type of vc to get
    /// - Returns: view controller
    func getViewController(_ passwordType: PFPasswordType) -> PasswordContainerViewController? {
        let storyboardIdentifier: String
        if passwordType == .advancedType || passwordType == .storedType {
            storyboardIdentifier = "BigContainer"
        } else {
            storyboardIdentifier = "Container"
        }
        
        if let vc = mainStoryboard?.instantiateViewController(withIdentifier: storyboardIdentifier) as? PasswordContainerViewController {
            vc.setType(type: passwordType)
            return vc
        }
        return nil
    }
    
    /// sets observers for all the values in defaults plist
    func setObservers() {
        guard let plist = d?.prefsPlist else {
            return
        }
        let defaults = DefaultsManager.standardDefaults()
        for (key, _) in plist {
            let k = String(describing: key)
            defaults?.addObserver(self, forKeyPath: k, options: .new, context: nil)
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //whenever a default changes, generate a password
    
        //TODO: do not generate on color changes
        if keyPath != "selectedPasswordType" {
            currentViewController?.generatePassword()
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
