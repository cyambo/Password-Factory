//
//  PassphrasePasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Controller for passphrase passwords
class PassphrasePasswordViewController: PasswordsViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        caseTypeView?.scrollToSelected()
        separatorTypeView?.scrollToSelected()
    }

}
