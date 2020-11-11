//
//  UpdateDomainsWorkerTests.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 20.10.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import XCTest
@testable import Flexx

class UpdateDomainsWorkerTests: XCTestCase {

    private var baseUrl: String {
        "http://localizer.upnetix.ut"
    }

    private var appId: String {
        "dummy-app-id"
    }

    private var apiUrl: URL {
        var urlComponents = URLComponents(string: baseUrl)!

        urlComponents.path = Constants.UpdateDomainsService.relativePath
        urlComponents.queryItems = [URLQueryItem(name: "app_id", value: appId)]

        return urlComponents.url!
    }

    private lazy var stubUrl: URL = {
        Bundle(for: UpdateDomainsWorkerTests.self)
            .url(forResource: "StubDomains", withExtension: "json")!
    }()

    private lazy var data: Data = {
        try! Data(contentsOf: stubUrl)
    }()

    private lazy var domains: [Domain] = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode([Domain].self, from: data)
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

    func testContractorShouldGetDomainsFromServer() {
        // Given
        // Create URL Session Configed with our Mock Protocol
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: sessionConfig)

        // Create configuration
        let configuration = FlexConfiguration(baseUrl: baseUrl,
                                              secret: "Doesn't matter",
                                              appId: appId,
                                              domains: [],
                                              shaValue: "Doesn't matter")

        // Create Contractor
        let networkService = RequestExecutorImp(urlSession)
        let sut = UpdateDomainsWorkerImp(networkService: networkService,
                                         configuration: configuration)



        // Create an expectation
        let expectation = self.expectation(description: "Domains")
        var _domains: [Domain]?
        var _error: UpdateDomainsError?

        // When
        sut.get { result in
            switch result {
            case .success(let newDomains):
                _domains = newDomains
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
        XCTAssertEqual(_domains,
                       domains,
                       "Domains returned from the service should match domains from the stub file.")
    }

}
