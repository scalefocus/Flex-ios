//
//  AppDelegate.swift
//  UpnetixLocalizerDemo
//
//  Created by Nadezhda Nikolova on 12/15/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import UIKit
import Flexx
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        let locale = Locale(identifier: "en-GB")
        Flexx.shared.initialize(locale: locale,
                                enableLogging: true,
                                defaultLoggingReturn: .key,
                                defaultUpdateInterval: 10000,
                                completed: nil)
        return true
    }
}
