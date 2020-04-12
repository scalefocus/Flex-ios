//
//  RequestExecutor.swift
//
//  Created by Nadezhda Nikolova on 11/24/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

class RequestExecutor {
    let configuration: Configuration
    let requestErrorHandler = RequestErrorHandler()
    let timeoutInterval = 30.0
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func execute(url: URL, method: Method, data: Data?, callback: @escaping (Data?) -> Void) {
        var request =  URLRequest(url: url,
                                  cachePolicy: .useProtocolCachePolicy,
                                  timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        request.httpBody = data
        
        // Authorization
        let authorizationValue = configuration.shaValue
        request.addValue(authorizationValue, forHTTPHeaderField: Constants.RequestExecutor.authHeader)
        request.addValue(Constants.RequestExecutor.contentTypeValue, forHTTPHeaderField: Constants.RequestExecutor.contentTypeHeader)
        Logger.log(messageFormat: "\(Constants.RequestExecutor.authHeader): \(authorizationValue)")
       
        let updateTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let strongSelf = self else {
                callback(nil)
                return
            }
            
            if strongSelf.requestErrorHandler.handleError(response: response, error: error) {
                callback(data)
            } else {
                callback(nil)
            }
        }
        updateTask.resume()
    }
}

enum Method: String {
    case get = "GET"
    case post = "POST"
}
