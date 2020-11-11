//
//  ConfigurationLoaderTest.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 20.10.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import XCTest
@testable import Flexx

class ConfigurationLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShouldLoadConfiguration() throws {
        // given
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")
        let configurationLoader = ConfigurationLoaderImp(bundleService)
        // when
        let configuration = try? configurationLoader.readConfigurationPlist()
        // then
        XCTAssertNotNil(configuration, "Configuration should not be nil")
    }

}
