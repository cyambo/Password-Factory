//
//  PatternPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// Controller for pattern password
class PatternPasswordViewController: PasswordsViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DefaultsManagerDelegate {

    @IBOutlet weak var patternButtonCollectionView: UICollectionView! //contains the pattern letter buttons
    @IBOutlet weak var typeLabel: UILabel! //displays the pattern type of the last entered letter
    @IBOutlet weak var patternText: PatternTextView! //pattern text
    var patternTextFont = UIFont.systemFont(ofSize: 32.0) //font for the pattern text

    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text = ""
        patternText.text = ""
        patternTextFont = patternText.font ?? patternTextFont
        if let p = d.object(forKey: "userPattern") {
            patternText.text = String(describing: p)
            highlightPatternString()
        }
        patternText.textContainer.lineBreakMode = .byCharWrapping
        patternText.textContainer.maximumNumberOfLines = 1
        
        patternButtonCollectionView.roundCorners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        patternText.contentOffset.y = -patternText.contentInset.top
        d.observeDefaults(self, keys: ["userPattern"]);
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        d.removeDefaultsObservers(self, keys: ["userPattern"])
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let sideMargin = Utilities.getSideMarginsForControls()
        view.layoutMargins = UIEdgeInsets(top: 8, left: sideMargin, bottom: 8, right: sideMargin)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //check to see if the last entered value is a newline
        if(text == "\n") {
            textView.resignFirstResponder() //if so, dismiss keyboard
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        typeLabel.text = ""
        if(textView.text.count > 0) {
            //setting the typeLabel to the type that was last entered
            if let lc = textView.text.last {
                let last = String(describing:lc)
                if let type = c.patternCharacterToType[last] {
                    typeLabel.text = c.patternTypeToDescription[type] ?? ""
                }
            }
        }
        updatePattern(patternText.text)
        highlightPatternString()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func updatePattern(_ pattern: String) {
        d.setObject(pattern, forKey: "userPattern")
        controlChanged(nil, defaultsKey: "userPattern")
    }
    
    /// highlights the pattern string, or uses default color based upon defaults
    func highlightPatternString() {
        let selection = patternText.selectedRange;
        if(d.bool(forKey: "colorPasswordText")) {
            highlightPattern()
        } else {
            patternText.attributedText = Utilities.getNonHighlightedString(s: patternText.text, font: patternTextFont)
        }
        patternText.selectedRange = selection
    }
    
    /// Highlights the pattern string based upon defaults
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatternItemCell", for: indexPath) as! PatternCollectionViewCell
        let pti = c.patternTypeIndex[indexPath.row]
        cell.setPatternTypeItem(pti)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let patternItem = c.patternTypeIndex[indexPath.row]
        let patternCharacter = c.patternTypeToCharacter[patternItem] ?? ""
        patternText.insertText(patternCharacter)
        typeLabel.text = c.patternTypeToDescription[patternItem] ?? ""
    }
    
    /// Clears the current pattern
    ///
    /// - Parameter sender: default sender
    @IBAction func clearPattern(_ sender: UIButton) {
        patternText.text = ""
        typeLabel.text = ""
        updatePattern("")

    }
    
    @IBAction func deleteLast(_ sender: Any) {
        patternText.text = String(patternText.text.dropLast())
        updatePattern(patternText.text)
        highlightPatternString()
    }
    
    func observeValue(_ keyPath: String?, change: [AnyHashable : Any]?) {
        if (keyPath == "userPattern") {
            guard let ch = change else { return }
            guard let s = ch["new"] as? String else { return }
            if (patternText.text != s) {
                patternText.text = s
                highlightPatternString()
            }
            
        }
    }
    
}
