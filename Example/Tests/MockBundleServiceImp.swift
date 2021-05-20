//
//  MockBundleServiceImp.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 23.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import Foundation
import Flexx

final class MockBundleServiceImp: BundleService {

    static let bundleFile = "bg-bundle-test"

    init (bundleId: String) {
        _bundleIdentifier = bundleId
    }

    var localizationsUrl: URL {
        URL(fileURLWithPath: "Test.app/Localizations")
    }

    private let _bundleIdentifier: String?
    var bundleIdentifier: String? {
        _bundleIdentifier
    }

    func url(forLocaleFile fileName: String, in domain: String) -> URL? {
        let url = domain.isEmpty ?
            localizationsUrl : localizationsUrl.appendingPathComponent(domain)
        return url
            .appendingPathComponent(fileName)
            .appendingPathExtension("json")
    }

    var configurationUrl: URL? {
        let bundle = Bundle(for: MockBundleServiceImp.self)
        return bundle.url(forResource: "StubFlexxConfig", withExtension: "plist")
    }

}
