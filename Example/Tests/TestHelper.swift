//
//  TestHelper.swift
//  UpnetixLocalizerDemo
//
//  Created by Aleksandar Sergeev Petrov on 21.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import Foundation

struct TestHelper {
    static let isRunningTests: Bool = {
        guard let injectBundle = ProcessInfo.processInfo.environment["XCTestBundlePath"] as NSString? else {
            return false
        }
        let pathExtension = injectBundle.pathExtension

        return pathExtension == "xctest" || pathExtension == "octest"
    }()
}
