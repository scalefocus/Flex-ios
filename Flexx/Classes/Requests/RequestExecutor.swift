//
//  RequestExecutor.swift
//
//  Created by Nadezhda Nikolova on 11/24/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

protocol RequestExecutor {
    func execute(url: URL,
                 method: Method,
                 token: String,
                 data: Data?,
                 callback: @escaping (Data?) -> Void)
}

/// RequestExecutor is thin wrapper around URLSession.
/// It creates tasks that are specifically setup to match Flex backend expectations.
final class RequestExecutorImp: RequestExecutor {

    let timeoutInterval = 30.0

    private let session: URLSession
    private let errorHandler: RequestErrorHandler

    // MARK: - Object lifecycle

    /// Initializes an RequestExecutorImp given session and error handler
    ///
    /// - Parameters:
    ///     - session:      An object that coordinates a group of related, network data-transfer tasks.
    ///     - errorHandler: An object that is resposible for the error handling of Flex backend responses
    init(_ session: URLSession = .shared,
         _ errorHandler: RequestErrorHandler = RequestErrorHandlerImp()) {
        self.session = session
        self.errorHandler = errorHandler
    }

    // MARK: - RequestExecutor

    /// Makes request to a URL and calls handler upon completion
    ///
    /// - Parameters:
    ///     - url:      The endpoint URL
    ///     - method:   The http request method (GET or POST)
    ///     - token:    The header value for authentication to the backend
    ///     - data:     The data that should be send to the server
    ///     - callback: The completion handler to call when the request is complete
    ///
    func execute(url: URL,
                 method: Method,
                 token: String,
                 data: Data?,
                 callback: @escaping (Data?) -> Void) {
        var request =  URLRequest(url: url,
                                  cachePolicy: .useProtocolCachePolicy,
                                  timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        request.httpBody = data
        
        // Authorization header
        request.addValue(token, forHTTPHeaderField: Constants.RequestExecutor.authHeader)
        Logger.log(messageFormat: "\(Constants.RequestExecutor.authHeader): \(token)")

        // other headers
        request.addValue(Constants.RequestExecutor.contentTypeValue,
                         forHTTPHeaderField: Constants.RequestExecutor.contentTypeHeader)

        let task = session.dataTask(with: request) { [errorHandler] (data, response, error) in
            if errorHandler.handleError(response: response, error: error) {
                callback(data)
            } else {
                callback(nil)
            }
        }
        task.resume()
    }
}

enum Method: String {
    case get = "GET"
    case post = "POST"
}
