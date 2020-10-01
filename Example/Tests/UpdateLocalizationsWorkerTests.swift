//
//  UpdateLocalizationsWorkerTests.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 29.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import XCTest
@testable import Flexx

class UpdateLocalizationsWorkerTests: XCTestCase {

    private var baseUrl: String {
        "http://localizer.upnetix.ut"
    }

    private var appId: String {
        "dummy-app-id"
    }

    private var apiUrl: URL {
        URL(string:baseUrl)!
            .appendingPathComponent(Constants.UpdateLocaleService.relativePath)
    }

    private lazy var stubUrl: URL = {
        Bundle(for: UpdateLocalizationsWorkerTests.self)
            .url(forResource: "StubUpdates", withExtension: "json")!
    }()

    private lazy var data: Data = {
        try! Data(contentsOf: stubUrl)
    }()

    private lazy var updates: UpdateTranslationsScheme = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode(UpdateTranslationsScheme.self, from: data)
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
        let sut = UpdateLocalizationsWorkerImp(networkService: networkService)

        let configuration = Configuration(baseUrl: baseUrl,
                                          secret: "Doesn't matter",
                                          appId: appId,
                                          domains: [],
                                          shaValue: "Doesn't matter")
        let scheme = UpdateTranslationsScheme(appId: appId,
                                              locale: "en-GB",
                                              domains: [])

        // Create an expectation
        let expectation = self.expectation(description: "Update")
        var _updates: UpdateTranslationsScheme?
        var _error: UpdateLocalizationsError?

        // When
        sut.post(scheme, for: configuration) { result in
            switch result {
            case .success(let newScheme):
                _updates = newScheme
            case .failure(let error):
                _error = error
            }

            // Fullfil the expectation to let the test runner
            // know that it's OK to proceed
            expectation.fulfill()
        }

        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)

        // Then
        XCTAssertNil(_error, "Error should be nil")
        XCTAssertEqual(_updates,
                       updates,
                       "Scheme returned from the service should match scheme from the stub file.")
    }

}
