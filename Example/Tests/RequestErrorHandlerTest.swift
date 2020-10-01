//
//  RequestErrorHandlerTest.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 28.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import XCTest
@testable import Flexx

class RequestErrorHandlerTest: XCTestCase {

    override func setUpWithError() throws {
        // Do something
    }

    override func tearDownWithError() throws {
        // Do something
    }

    func testHandleErrorShouldReturnFalseIfErrorIsNotNil() {
        // Given
        let error = NSError(domain: "com.upnetix.flexx.ut.error",
                            code: -1000,
                            userInfo: nil)
        let response = HTTPURLResponse(url: URL(string: "https://test.com/test")!,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: nil)
        let sut = RequestErrorHandlerImp()
        // When
        let result = sut.handleError(response: response, error: error)
        // Then
        XCTAssertFalse(result, "Should return false")
    }

    func testHandleErrorShouldReturnFalseIfResponseIsNil() {
        // Given
        let sut = RequestErrorHandlerImp()
        // When
        let result = sut.handleError(response: nil, error: nil)
        // Then
        XCTAssertFalse(result, "Should return false")
    }

    func testHandleErrorShouldReturnFalseIfStatusCodeIsNotValid() {
        // Given
        let response = HTTPURLResponse(url: URL(string: "https://test.com/test")!,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: nil)
        let sut = RequestErrorHandlerImp()
        // When
        let result = sut.handleError(response: response, error: nil)
        // Then
        XCTAssertFalse(result, "Should return false")
    }

    func testHandleErrorShouldReturnTrueIfStatusCodeIsValid() {
        // Given
        let response = HTTPURLResponse(url: URL(string: "https://test.com/test")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        let sut = RequestErrorHandlerImp()
        // When
        let result = sut.handleError(response: response, error: nil)
        // Then
        XCTAssert(result, "Should return true")
    }

}
