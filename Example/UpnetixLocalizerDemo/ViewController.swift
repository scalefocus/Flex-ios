//
//  ViewController.swift
//  UpnetixLocalizerDemo
//
//  Created by Nadezhda Nikolova on 12/15/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import UIKit
import Flexx

class ViewController: UIViewController {
    
    @IBOutlet private weak var firstLabel: UILabel!
    @IBOutlet private weak var secondLabel: UILabel! {
        didSet {
            secondLabel.text = Flexx.shared.getString(domain: "Common", key: "name")
        }
    }
    @IBOutlet private weak var thirdLabel: UILabel!

    var text = ""
    var translation = ""
    var lang: [Language] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondLabel.text = Flexx.shared.getString(domain: "Common", key: "name")
        
        Flexx.shared.getAvailableLocales(withCompletion: { languages, error in
            self.lang = languages
        })
    }
    
    @IBAction func reloadInputViews(_ sender: Any) {
        firstLabel.text = self.text
        secondLabel.text = self.translation
    }
    
    @IBAction func switchLanguage(_ sender: UISwitch) {
        
        self.text = ""
        self.translation = ""
        
        self.lang.enumerated().forEach { lang in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                Flexx.shared.changeLocale(desiredLocale: Locale(identifier: lang.element.code)) {
                    let tex = Flexx.shared.getString(domain: "Common", key: "name")
                    self.translation.append("\n\(tex) for lang \(lang.element.name)")
                }
            }
        }
    }
    
    //        let locale = sender.isOn ? "en-GB" : "bg"
    //
    //        Flexx.shared.changeLocale(desiredLocale: Locale(identifier: locale)) { [weak self] in
//            self?.firstLabel.text = Flexx.shared.getString(domain: "Domain", key: "key")
//        }
    
}

/*
 Flexx.shared.getAvailableLocales(withCompletion: { languages, error in
     for language in languages {
         print("\n\(language.name)")
         //                Flexx.shared.getString(domain: "Common", key: "name")
         Flexx.shared.changeLocale(desiredLocale: Locale(identifier: language.code)) {
             let tex = Flexx.shared.getString(domain: "Common", key: "name")
             print("\n\(tex) for lang \(language.code)")
         }
         sleep(3)
     }
 })
*/
