//
//  PasswordsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PasswordsViewController: UIViewController {

    var passwordViewController: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setup(type: PFPasswordType) {
        let typeName = PasswordFactoryConstants.get().getNameFor(type) ?? "random"
        let storyboardIdentfier = typeName + "Password"
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        passwordViewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentfier)
        self.view = passwordViewController?.view
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
