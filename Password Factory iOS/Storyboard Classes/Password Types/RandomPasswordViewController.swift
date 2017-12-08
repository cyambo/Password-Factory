//
//  RandomPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class RandomPasswordViewController: PasswordsViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLengthSlider()
        lengthChanged()
        setSwitch(s: avoidAmbiguousSwitch, defaultsKey: "randomAvoidAmbiguous")
        setSwitch(s: useNumbersSwitch, defaultsKey: "randomUseNumbers")
        setSwitch(s: useSymbolsSwitch, defaultsKey: "randomUseSymbols")
        setSwitch(s: useEmojiSwitch, defaultsKey: "randomUseEmoji")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        caseTypeView?.scrollToSelected()
    }
}
