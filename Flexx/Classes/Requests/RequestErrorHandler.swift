//
//  RequestErrorhandler.swift
//
//  Created by nikolay.prodanov on 10/31/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

// TODO: Add Protocol, Refactor, Unit Tests
final class RequestErrorHandler {
    /// Check if there is some error with request response and Log a proper message about it.
    ///
    /// - Parameters:
    ///   - response: Requests's response if there is such
    ///   - error: Error value if there is such
    /// - Returns: Bool value representing if request is successful
    func handleError(response: URLResponse?, error: Error?) -> Bool {
        var wasSuccessful = true
        if let error = error {
            // Some kind of network error
            Logger.log(messageFormat: Constants.RequestErrorHandler.httpRequestError, args: [error.localizedDescription])
            wasSuccessful = false
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            let successfulRequest = (HttpStatusCode.ok.rawValue ..< HttpStatusCode.multipleChoises.rawValue) ~= httpResponse.statusCode
            if !successfulRequest {
                //HTTP error
                Logger.log(messageFormat: Constants.RequestErrorHandler.requestHttpResponseError, args: [httpResponse.debugDescription])
                wasSuccessful = false
            }
        } else {
            // Some kind of network error
            if !response.debugDescription.isEmpty {
            Logger.log(messageFormat: Constants.RequestErrorHandler.requestResponseError, args: [response.debugDescription])
            }
            wasSuccessful = false
        }
        
        return wasSuccessful
    }
    
    /// Logs message about creating request error
    func handleRequestCreationError() {
        // For now will only Log the error
        Logger.log(messageFormat: Constants.RequestErrorHandler.couldNotCreateUrlRequest)
    }
}
