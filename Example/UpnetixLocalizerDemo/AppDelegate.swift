//
//  AppDelegate.swift
//  UpnetixLocalizerDemo
//
//  Created by Nadezhda Nikolova on 12/15/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import UIKit
import Flexx

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Prevent setup Flexx during unit tests
        #if DEBUG
            guard !TestHelper.isRunningTests else {
                return true
            }
        #endif // DEBUG
        
        let locale = Locale(identifier: "en-GB")
        Flexx.shared.initialize(locale: locale,
                                enableLogging: true,
                                defaultLoggingReturn: .key)
        return true
    }
}
