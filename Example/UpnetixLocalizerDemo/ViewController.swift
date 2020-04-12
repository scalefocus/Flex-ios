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
    @IBOutlet private weak var secondLabel: UILabel!
    @IBOutlet private weak var thirdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstLabel.text = Flexx.shared.getString(domain: "Domain", key: "key")
    }
    
    @IBAction func reloadInputViews(_ sender: Any) {
        firstLabel.text = Flexx.shared.getString(domain: "Domain", key: "key")
    }
    
    @IBAction func switchLanguage(_ sender: UISwitch) {
        let locale = sender.isOn ? "en-GB" : "bg"
        
        Flexx.shared.changeLocale(desiredLocale: Locale(identifier: locale)) { [weak self] in
            self?.firstLabel.text = Flexx.shared.getString(domain: "Domain", key: "key")
        }
    }
}
