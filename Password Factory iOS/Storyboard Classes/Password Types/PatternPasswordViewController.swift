//
//  PatternPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PatternPasswordViewController: PasswordsViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var patternText: PatternTextView!
    var patternTextFont = UIFont.systemFont(ofSize: 32.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text = ""
        patternText.text = ""
        patternTextFont = patternText.font ?? patternTextFont
        patternText.textContainer.lineBreakMode = .byCharWrapping
        if let p = d.object(forKey: "userPattern") {
            patternText.text = String(describing: p)
            highlightPatternString()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    func textViewDidChange(_ textView: UITextView) {
        typeLabel.text = ""
        //checking to see if a newline was entered, that means 'done' was pressed on the keyboard and need to dismiss it
        if(textView.text.last == "\n") {
            //remove the newline, because it doesn't make sense in the pattern
            textView.text.remove(at: textView.text.index(before: textView.text.endIndex))
            //dismiss the keyboard
            textView.resignFirstResponder()
        } else if(textView.text.count > 0) {
            //setting the typeLabel to the type that was last entered
            let last = String(describing:textView.text.last)
            if let type = c.patternCharacterToType[last] {
                typeLabel.text = c.patternTypeToDescription[type] ?? ""
            }
        }
        d.setObject(patternText.text, forKey: "userPattern")
        highlightPatternString()
    }
    func highlightPatternString() {
        if(d.bool(forKey: "colorPasswordText")) {
            highlightPattern()
        } else {
            patternText.attributedText = Utilities.getNonHighlightedString(s: patternText.text, font: patternTextFont)
        }
    }
    func highlightPattern() {
        let highlighted = NSMutableAttributedString()
        let defaultColor = ColorUtilities.getDefaultsColor("defaultTextColor")
        for index in patternText.text.indices {
            var color = defaultColor
            let char = patternText.text[index]
            let s = String(describing:char)
            if(s.count == 1) {
                if let pType = c.patternCharacterToType[s] {
                    color = ColorUtilities.patternType(toColor: pType)
                }
            }
            let attrs = [
                NSAttributedStringKey.foregroundColor:color as Any,
                NSAttributedStringKey.font: patternTextFont
            ]
            let hChar = NSAttributedString.init(string: s, attributes: attrs)
            highlighted.append(hChar)
        }
        patternText.attributedText = highlighted
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return c.patternTypeIndex.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //putting the pattern letter in each cell, and highlighting it
        //based upon the pattern color
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatternItemCell", for: indexPath) as! PatternCollectionViewCell
        let pti = c.patternTypeIndex[indexPath.row]
        let pc = c.patternTypeToCharacter[pti]
        cell.patternItemText.text = pc
        cell.patternItemText.textColor = ColorUtilities.patternType(toColor: pti)
        Utilities.roundCorners(layer: cell.layer, withBorder: true)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let patternItem = c.patternTypeIndex[indexPath.row]
        let patternCharacter = c.patternTypeToCharacter[patternItem] ?? ""
        patternText.insertText(patternCharacter)
        typeLabel.text = c.patternTypeToDescription[patternItem] ?? ""
    }
    
    @IBAction func clearPattern(_ sender: UIButton) {
        patternText.text = ""
        typeLabel.text = ""
        d.setObject("", forKey: "userPattern")
    }
}
