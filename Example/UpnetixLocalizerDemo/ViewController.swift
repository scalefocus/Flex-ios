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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondLabel.text = Flexx.shared.getString(domain: "Common", key: "name")
    }
    
    @IBAction func reloadInputViews(_ sender: Any) {
        firstLabel.text = self.text
        secondLabel.text = self.translation
    }
    
    @IBAction func switchLanguage(_ sender: UISwitch) {

        self.text = ""
        self.translation = ""

        Flexx.shared.getAvailableLocales(withCompletion: { languages, error in
            for language in languages {
                self.text.append("\n\(language.name)")
                //                Flexx.shared.getString(domain: "Common", key: "name")
                Flexx.shared.changeLocale(desiredLocale: Locale(identifier: language.code)) {
                    let tex = Flexx.shared.getString(domain: "Common", key: "name")
                    self.translation.append("\n\(tex) for lang \(language.code)")
                }
            }
        })

//        let locale = sender.isOn ? "en-GB" : "bg"
//
//        Flexx.shared.changeLocale(desiredLocale: Locale(identifier: locale)) { [weak self] in
//            self?.firstLabel.text = Flexx.shared.getString(domain: "Domain", key: "key")
//        }
    }
}
