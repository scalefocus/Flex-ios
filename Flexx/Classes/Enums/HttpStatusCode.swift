//
//  HttpStatusCode.swift
//
//  Created by Пламен Великов on 11/16/16.
//  Copyright © 2017 Upnetix. All rights reserved.
//

enum HttpStatusCode: Int {
    case ok = 200
    case noContent = 204
    case multipleChoises = 300
    case invalidTokenError = 401
}

enum ValidationType {
    /// No validation.
    case none

    /// Validate success codes (only 2xx).
    case successCodes

    /// Validate success codes and redirection codes (only 2xx and 3xx).
    case successAndRedirectCodes

    /// Validate only the given status codes.
    case customCodes([Int])

    /// The list of HTTP status codes to validate.
    var statusCodes: [Int] {
        switch self {
        case .successCodes:
            return Array(200..<300)
        case .successAndRedirectCodes:
            return Array(200..<400)
        case .customCodes(let codes):
            return codes
        case .none:
            return []
        }
    }
}
