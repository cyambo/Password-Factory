//
//  PronounceablePasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PronounceablePasswordViewController: PasswordsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLengthSlider()
        lengthChanged()
    }

}
