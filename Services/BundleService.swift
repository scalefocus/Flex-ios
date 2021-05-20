//
//  BundleService.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 21.09.20.
//

import Foundation

public protocol BundleService {
    var localizationsUrl: URL { get }
    var bundleIdentifier: String? { get }
    func url(forLocaleFile fileName: String, in domain: String) -> URL?

    var configurationUrl: URL? { get }
}

public final class BundleServiceImpl: BundleService {

    private let bundle: Bundle

    // This approach will allow us to mock Bundle
    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    // MARK: - BundleService

    /// - Returns: Localizations directory in bundle
    public var localizationsUrl: URL {
        bundle.bundleURL
            .appendingPathComponent(Constants.FileHandler.localizationsPath)
    }

    /// - Returns: Bundle identifier
    public var bundleIdentifier: String? {
        bundle.bundleIdentifier
    }

    /// - Returns: The URL for locale file in bundle
    public func url(forLocaleFile fileName: String, in domain: String) -> URL? {
        let directory = Constants.FileHandler.localizationsPath
        let subdirectory = domain.isEmpty ?
            directory : (directory as NSString).appendingPathComponent(domain)
        return bundle.url(forResource: fileName,
                          withExtension: Constants.FileHandler.jsonFileExtension,
                          subdirectory: subdirectory,
                          localization: nil)
    }

    /// - Returns: The URL to `FlexxConfig.plist` file
    public var configurationUrl: URL? {
        bundle.url(forResource: Constants.ConfigurationLoader.configurationPlistFileName,
                   withExtension: Constants.FileHandler.plistFileExtension)
    }
}
