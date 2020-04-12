//
//  Configuration.swift
//
//  Created by Nadezhda Nikolova on 11/21/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

/// Configuration object is used for passing project specific information like base url,
/// secret and appId.
/// JSON for this object is generated in Configuration.plist
///
/// - baseUrl: the strings provider service URL
/// - secret: used for authentication for calls to the library
/// - appId: the identifier of the application, should be unique for your app
/// - domains: array of strings that contains all domains id-s
/// - shaValue: the header value for authentication to the backend
struct Configuration {
    let baseUrl: String
    let secret: String
    let appId: String
    let domains: [String]
    let shaValue: String
}
