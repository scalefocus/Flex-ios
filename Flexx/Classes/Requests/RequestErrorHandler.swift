//
//  RequestErrorhandler.swift
//
//  Created by nikolay.prodanov on 10/31/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

protocol RequestErrorHandler {
    func handleError(response: URLResponse?, error: Error?) -> Bool
}

/// An object that is resposible for the error handling of Flex backend responses
final class RequestErrorHandlerImp: RequestErrorHandler {

    /// Http status code validation. Default is accept only success status codes.
    var validationType: ValidationType {
        .successCodes
    }

    /// Check if there is some error with request response and Log a proper message about it.
    ///
    /// - Parameters:
    ///   - response: Requests's response if there is such
    ///   - error: Error value if there is such
    ///
    /// - Returns: Bool value representing if request is successful
    func handleError(response: URLResponse?, error: Error?) -> Bool {
        if let error = error {
            Logger.log(messageFormat: Constants.RequestErrorHandler.httpRequestError,
                       args: [error.localizedDescription])
            return false
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.log(messageFormat: Constants.RequestErrorHandler.requestResponseError)
            return false
        }

        let validCodes = validationType.statusCodes
        guard validCodes.isEmpty || validCodes.contains(httpResponse.statusCode) else {
            Logger.log(messageFormat: Constants.RequestErrorHandler.httpRequestError,
                       args: [httpResponse.debugDescription])
            return false
        }

        return true
    }

}
