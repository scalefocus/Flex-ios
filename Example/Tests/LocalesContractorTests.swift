//
//  LocalesContractorTests.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 28.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import XCTest
@testable import Flexx

class LocalesContractorTests: XCTestCase {

    private var baseUrl: String {
        "http://localizer.upnetix.ut"
    }

    private var appId: String {
        "dummy-app-id"
    }

    private var apiUrl: URL {
        URL(string:
                baseUrl
                + Constants.LocalesContractor.relativePath
                + "?app_id=\(appId)"
        )!
    }

    private lazy var stubUrl: URL = {
        Bundle(for: LocalesContractorTests.self)
            .url(forResource: "StubLocales", withExtension: "json")!
    }()

    private lazy var data: Data = {
        try! Data(contentsOf: stubUrl)
    }()

    private lazy var languages: [Language] = {
        let decoder = JSONDecoder()
        return try! decoder.decode([Language].self, from: data)
    }()

    override func setUpWithError() throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: self.apiUrl,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, self.data)
        }

    }

    override func tearDownWithError() throws {
        // Do something
    }

    func testContractorShouldGetLanguagesFromServer() {
        // Given
        // Create URL Session Configed with our Mock Protocol
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: sessionConfig)

        // Create Contractor
        let networkService = RequestExecutorImp(urlSession)
        let sut = LocalesContractorImp(networkService: networkService,
                                              localeFileHandler: .default)

        let configuration = FlexConfiguration(baseUrl: baseUrl,
                                              secret: "Doesn't matter",
                                              appId: appId,
                                              domains: [],
                                              shaValue: "Doesn't matter")

        // Create an expectation
        let expectation = self.expectation(description: "Languages")
        var _languages: [Language] = []

        // When
        sut.localesFromServer(for: configuration) { result in
            _languages = result

            // Fullfil the expectation to let the test runner
            // know that it's OK to proceed
            expectation.fulfill()
        }

        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)

        // Then
        XCTAssertEqual(_languages.count,
                       languages.count,
                       "Languages returned from the service should match languages from the stub file.")
    }

    func testContractorShouldLoadLanguagesFromFile() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")
        let localeFileHandler = LocaleFileHandler(settingsService,
                                                  fileService,
                                                  bundleService)
        let sut = LocalesContractorImp(networkService: RequestExecutorImp(),
                                       localeFileHandler: localeFileHandler)
        // When
        let result = sut.localesFromFiles(in: "Test")
        // Then
        XCTAssert(result.count == MockFileServiceImp.bundleFiles.count,
                  "The number of files in the array should match bundled files")
    }

    func testContractorShouldNotLoadLanguagesFromFile() {
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")
        let localeFileHandler = LocaleFileHandler(settingsService,
                                                  fileService,
                                                  bundleService)
        let sut = LocalesContractorImp(networkService: RequestExecutorImp(),
                                       localeFileHandler: localeFileHandler)
        // When
        let result1 = sut.localesFromFiles(in: nil)
        let result2 = sut.localesFromFiles(in: "")
        // Then
        XCTAssert(result1.isEmpty, "Result array should be empty when domain is nil")
        XCTAssert(result2.isEmpty, "Result array should be empty when domain is empty string")
    }

}
