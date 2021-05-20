//
//  UpdateTranslationsScheme.swift
//
//  Created by Nadezhda Nikolova on 12/21/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

/// This class describes the scheme for updating translations
struct UpdateTranslationsScheme: Codable {
    /// The Unique Identifier of the application
    let appId: String
    /// Locale code
    let locale: String
    /// List of domains that keep translations
    let domains: [Domain]
    /// Update Interval in milliseconds
    let updateInterval: Int?
    /// Warnings list received in response from backend when updating locales
    let warnings: [String]?

    init(appId: String,
         locale: String,
         domains: [Domain],
         updateInterval: Int? = nil,
         warnings: [String]? = nil) {
        self.appId = appId
        self.locale = locale
        self.domains = domains
        self.updateInterval = updateInterval
        self.warnings = warnings
    }
}

// MARK: - Equatable extension

extension UpdateTranslationsScheme: Equatable {
    static func == (left: UpdateTranslationsScheme, right: UpdateTranslationsScheme) -> Bool {
        return left.appId == right.appId
            && left.locale == right.locale
            && left.updateInterval == right.updateInterval
            && left.domains == right.domains
    }
}
