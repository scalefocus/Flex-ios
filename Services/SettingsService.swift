//
//  SettingsService.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 18.09.20.
//

import Foundation

public protocol SettingsService {
    var lastVersion: Int { get set }
}

public final class SettingsServiceImpl: SettingsService {

    private let userDefaults: UserDefaults

    // This approach will allow us to mock UserDefaults
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public var lastVersion: Int {
        get {
            let version = userDefaults
                .value(forKey: Constants.UserDefaultKeys.zipFileVersion)
            return version as? Int ?? .invalidVersion
        }
        set {
            userDefaults.set(newValue, forKey: Constants.UserDefaultKeys.zipFileVersion)
        }
    }

}
