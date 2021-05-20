//
//  FlexConfiguration.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 20.10.20.
//

import Foundation

/// Configuration object is used for passing project specific information like base url,  secret and appId.
/// The JSON representation of this object is stored in Configuration.plist
final class FlexConfiguration {
    /// The service URL
    let baseUrl: String

    /// The secred used for authentication with the service
    let secret: String

    /// An unique the identifier of the application
    let appId: String

    /// An array of strings that contains all domains id-s
    let domains: [String]

    // The header value for authentication to the backend
    let shaValue: String

    enum PlistKeys: String {
        case baseUrl    = "BaseUrl"
        case secret     = "Secret"
        case appId      = "AppId"
        case domains    = "Domains"
        case shaValue   = "ShaValue"
    }

    // MARK: - Object lifecycle

    convenience init?(with plist: PropertyList) {
        guard let appId = plist[PlistKeys.appId.rawValue] as? String,
              let shaValue = plist[PlistKeys.shaValue.rawValue] as? String,
              let baseUrl = plist[PlistKeys.baseUrl.rawValue] as? String,
              let secret = plist[PlistKeys.secret.rawValue] as? String,
              let domains = plist[PlistKeys.domains.rawValue] as? [String] else {
            Logger.log(messageFormat: Constants.Localizer.errorInConfigurationInitialization)
            return nil
        }
        self.init(baseUrl: baseUrl, secret: secret, appId: appId, domains: domains, shaValue: shaValue)
    }

    init(baseUrl: String, secret: String, appId: String, domains: [String], shaValue: String) {
        self.appId = appId
        self.shaValue = shaValue
        self.baseUrl = baseUrl
        self.secret = secret
        self.domains = domains
    }
}

// MARK: - Configuration Loader

protocol ConfigurationLoader {
    func readConfigurationPlist() throws -> FlexConfiguration
}

typealias PropertyList = [String : Any]

/// Helper class used to load `FlexConfiguration` from `FlexxConfig.plist`
final class ConfigurationLoaderImp: ConfigurationLoader {

    // MARK: - Dependecies

    private let bundleService: BundleService

    // MARK: - Object lifecycle

    init(_ bundleService: BundleService = BundleServiceImpl()) {
        self.bundleService = bundleService
    }

    // MARK: - ConfigurationLoader

    /// Returns the `FlexConfiguration` for the `FlexxConfig.plist`
    func readConfigurationPlist() throws -> FlexConfiguration {
        guard let url = bundleService.configurationUrl, let data = try? Data(contentsOf: url) else {
            Logger.log(messageFormat: Constants.ConfigurationLoader.errorPlistNotFound)
            throw ConfigurationLoaderError.configurationNotFound
        }

        guard let plist = try self.plistContent(from: data) as? PropertyList else {
            Logger.log(messageFormat: Constants.ConfigurationLoader.errorInvalidContent)
            throw ConfigurationLoaderError.configurationInvalidContent
        }

        guard let configuration = FlexConfiguration(with: plist) else {
            throw ConfigurationLoaderError.configurationInitialization
        }

        return configuration
    }

    // MARK: - Helpers

    private func plistContent(from data: Data) throws -> Any? {
        do {
            return try PropertyListSerialization.propertyList(from: data, format: nil)
        } catch {
            Logger.log(messageFormat: error.localizedDescription)
            throw ConfigurationLoaderError.configurationDecodingFailed(error: error)
        }
    }

}

// MARK: - Custom Error

enum ConfigurationLoaderError: Error {
    case configurationNotFound
    case configurationDecodingFailed(error: Error)
    case configurationInvalidContent
    case configurationInitialization
}
