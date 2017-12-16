//
//  RandomPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Controller for random passwords
class RandomPasswordViewController: PasswordsViewController {

    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        scrollContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        scrollContainer.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

//        DispatchQueue.main.async {
//            var contentRect = CGRect.zero
//            for view in self.scrollView.subviews {
//                contentRect = contentRect.union(view.frame)
//                self.scrollView.contentSize = contentRect.size
//
//            }
//        }
    }

}
