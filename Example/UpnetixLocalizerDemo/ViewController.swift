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
    
    @IBOutlet weak var commonDomainLabel: UILabel!
    @IBOutlet weak var newDomainLabel: UILabel!
    @IBOutlet weak var secondDomainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonDomainLabel.text = Flexx.shared.getString(domain: "Common", key: "name")
        newDomainLabel.text = Flexx.shared.getString(domain: "Common", key: "ime")
        secondDomainLabel.text = Flexx.shared.getString(domain: "Domain", key: "namee")

//        Flex.shared.getAvailableLocales { locales, args  in
//            for language in locales {
//                print("LANGUAGE: \(language.code), \(language.name)")
//            }
//            if let args = args {
//                print("args: \(args)")
//            }
//        }
        
    }
    
    @IBAction func reloadInputViews(_ sender: Any) {
        commonDomainLabel.text = Flexx.shared.getString(domain: "Common", key: "name")
        newDomainLabel.text = Flexx.shared.getString(domain: "Common", key: "ime")
        secondDomainLabel.text = Flexx.shared.getString(domain: "Domain", key: "namee")
    }
    
    @IBAction func switchLanguage(_ sender: UISwitch) {
        let locale = sender.isOn ? "en-GB" : "bg"
        
        Flexx.shared.changeLocale(desiredLocale: Locale(identifier: locale)) { [weak self] in
            self?.commonDomainLabel.text = Flexx.shared.getString(domain: "Common", key: "name")
            self?.newDomainLabel.text = Flexx.shared.getString(domain: "Common", key: "ime")
            self?.secondDomainLabel.text = Flexx.shared.getString(domain: "Domain", key: "namee")
        }
    }
}
