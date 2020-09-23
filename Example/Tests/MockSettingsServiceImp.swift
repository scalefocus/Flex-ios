//
//  MockSettingsServiceImp.swift
//  UpnetixLocalizerDemo
//
//  Created by Aleksandar Sergeev Petrov on 23.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import Foundation
@testable import Flexx

final class MockSettingsServiceImp: SettingsService {
    private var data: Dictionary<String, Any?> = [:]
    private let lastVersionKey = "zipfile-version"

    var lastVersion: Int {
        get {
            data[lastVersionKey] as? Int ?? .invalidVersion
        }
        set {
            data[lastVersionKey] = newValue
        }
    }

    // sugar
    var isZipFileVersionChanged: Bool {
        data[lastVersionKey] != nil
    }
}
