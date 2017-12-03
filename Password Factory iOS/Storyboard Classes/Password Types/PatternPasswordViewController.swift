//
//  PatternPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PatternPasswordViewController: PasswordsViewController, UITextViewDelegate {

    @IBOutlet weak var patternText: PatternTextView!
    @IBOutlet weak var insertPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInsertPicker()
    }
    func setupInsertPicker() {
        
    }
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return c.patternTypeIndex.count + 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //zero row is insert menu
        if(row > 0) {
            
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (row == 0) {
            return "Insert"
        } else {
            let pt = getPatternTypeItemFromIndex(index: (row - 1))
            if let name = c.getNameFor(pt) {
                return name
            }
            return ""

        }
    }
    func getPatternTypeItemFromIndex(index: Int) -> PFPatternTypeItem {
        let rawType = c.patternTypeIndex[index] as? Int ?? PFPatternTypeItem.randomItemType.rawValue
        return PFPatternTypeItem(rawValue: rawType) ?? .randomItemType
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
