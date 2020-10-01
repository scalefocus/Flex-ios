//
//  TranslationsStore.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 28.09.20.
//

import Foundation

/// CRUD operations - Repository pattern
protocol TranslationsStore: class {
    // create & update
    func store(domain: String, translations: [String : String])
    func store(domain: String, version: Int)

    // Read
    func string(forKey key: String, in domain: String) -> String?
    func translations(in domain: String) -> [String: String]?
    func allDomainsVersions()  -> [String: Int]

    // Delete
    func clearAllTranslations()
    func clearAllDomainsVersions()
}

// NOTE: `threadSafeTranslations` & `threadSafeDomainsVersions` can be removed.
// Then all sync logic can be directly implemented in the CRUD methods.

/// This object caches all translations in the memory
final class TranslationsStoreImp: TranslationsStore {

    /// ConcurrentQueue for managing the reading and writing to transactions.
    private let concurrentQueue = DispatchQueue(label: "concurrentQueue",
                                                qos: .userInteractive,
                                                attributes: .concurrent)

    /// The first string is the Domain name and it holds dictionary of [String: String]
    /// which are the transactions for the current domain
    private var translations: [String: [String: String]] = [:]

    /// Synchronizing the access to the translations since it may appear
    /// simultaneously from multiple threads
    private var threadSafeTranslations: [String: [String: String]] {
        get {
            return concurrentQueue.sync { [unowned self] in
                self.translations
            }
        }
        set {
            concurrentQueue.async(flags: .barrier) { [unowned self] in
                self.translations = newValue
            }
        }
    }

    /// Holds the domain name and version
    private var domainsVersions: [String: Int] = [:]

    /// Synchronizing the access to the domainsVersions since it may appear
    /// simultaneously from multiple threads
    private var threadSafeDomainsVersions: [String: Int] {
        get {
            return concurrentQueue.sync { [unowned self] in
                self.domainsVersions
            }
        }
        set {
            concurrentQueue.async(flags: .barrier) { [unowned self] in
                self.domainsVersions = newValue
            }
        }
    }
}

// MARK: - CRUD operations

extension TranslationsStoreImp {
    /// Store Translations For one Domain.
    /// - parameter translations: contain translations we should store in our dictionary
    /// - parameter domain: domain's name
    func store(domain: String, translations: [String : String]) {
        threadSafeTranslations[domain] = translations
    }

    /// Store DomainsVersions
    /// - parameter version: domain's version
    /// - parameter domain: domain's name
    func store(domain: String, version: Int) {
        threadSafeDomainsVersions[domain] = version
    }

    /// Retreives value from a key-value collection
    /// - parameter domain: domain that holds the translations
    /// - parameter key: key of the string
    /// - returns: string value representing the value for the requested key
    func string(forKey key: String, in domain: String) -> String? {
        threadSafeTranslations[domain]?[key]
    }

    /// Retreives all stored translations for given domain
    /// - parameter domain: domain's name
    /// - returns: dictionary that contains all translations in the domain
    func translations(in domain: String) -> [String: String]? {
        threadSafeTranslations[domain]
    }

    /// Retreives all stored domains' versions
    /// - returns: dictionary
    func allDomainsVersions() -> [String: Int] {
        threadSafeDomainsVersions
    }

    /// Clears stored translations in all domains
    func clearAllTranslations() {
        threadSafeTranslations = [:]
    }

    /// Clears all domains' versions
    // !!! Not used for now
    func clearAllDomainsVersions() {
        threadSafeDomainsVersions = [:]
    }
}
