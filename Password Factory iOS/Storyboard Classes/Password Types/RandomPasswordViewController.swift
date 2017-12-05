//
//  RandomPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class RandomPasswordViewController: PasswordsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLengthSlider()
        lengthChanged()
        setSwitch(s: avoidAmbiguousSwitch, defaultsKey: "randomAvoidAmbiguous")
        setSwitch(s: useNumbersSwitch, defaultsKey: "randomUseNumbers")
        setSwitch(s: useSymbolsSwitch, defaultsKey: "randomUseSymbols")
        setSwitch(s: useEmojiSwitch, defaultsKey: "randomUseEmoji")
        setupCaseType()

    }
    

}
