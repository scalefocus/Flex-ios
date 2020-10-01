//
//  StoreLocalizationsWorker.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 28.09.20.
//

import Foundation

typealias UpdateServiceHandler = () -> Void

protocol StoreLocalizationsWorker {
    func store(receivedScheme: UpdateTranslationsScheme)
    func scheme(locale: String, for configuration: Configuration) -> UpdateTranslationsScheme
}

/// Stores upates in translations
final class StoreLocalizationsWorkerImp: StoreLocalizationsWorker {
    private let translationsStore: TranslationsStore
    private let fileHandler: LocaleFileHandler
    private let defaultUpdateInterval: Int

    // MARK: - Object lifecycle

    /// Initializes an StoreLocalizationsWorkerImp with given store, locale file handler and repeating interval
    ///
    /// - Parameters:
    ///     - translationsStore:        Translations in-memory cache
    ///     - fileHandler:              Handles data persistence
    ///     - defaultUpdateInterval:    A time interval in millisconds
    init(translationsStore: TranslationsStore,
         fileHandler: LocaleFileHandler,
         defaultUpdateInterval: Int) {
        self.translationsStore = translationsStore
        self.fileHandler = fileHandler
        self.defaultUpdateInterval = defaultUpdateInterval
    }

    // MARK: - StoreLocalizationsWorker


    /// Stores the new scheme information. First persists the whole information in a file. Then caches translations in memory.
    ///
    /// - parameter receivedScheme:    The scheme for updating translations
    func store(receivedScheme: UpdateTranslationsScheme) {
        handleWarnings(from: receivedScheme)

        receivedScheme.domains.forEach { (domain) in
            // try read and flat domain translations
            // continue to next domain if we don't have anything new
            guard let newTranslation = translations(in: domain), !newTranslation.isEmpty else {
                return
            }
            // !!! Empty old translations should not be an error case
            var oldTranslations = translationsStore.translations(in: domain.domainId) ?? [:]
            // merge new transaltions into old one
            oldTranslations.merge(dict: newTranslation)
            // wrap result in internal object
            let localeTranslations = LocaleTranslations(domainId: domain.domainId,
                                                        appId: receivedScheme.appId,
                                                        version: domain.version,
                                                        locale: receivedScheme.locale,
                                                        updateInterval: defaultUpdateInterval,
                                                        translations: oldTranslations)
            // encode object and store it in a file
            // !!! Don't handle the result because:
            // 1. We don't even need to log the error. It is already done in `write`.
            // 2. Also we will work with the in-memory store, so we don't need file for now.
            _ = write(translations: localeTranslations)

            // Store in-memory as well
            translationsStore.store(domain: domain.domainId,
                                    translations: oldTranslations)
            translationsStore.store(domain: domain.domainId,
                                    version: domain.version)
        }
    }

    /// Constructs `UpdateTranslationsScheme` object for given locale and configuration
    ///
    /// - Parameters:
    ///     - locale:           Locale identifier
    ///     - configuration:    Project specific configuration
    ///
    /// - Returns the scheme for updating the translations
    func scheme(locale: String, for configuration: Configuration) -> UpdateTranslationsScheme {
        let domainsVersions = translationsStore.allDomainsVersions()
        let domains = domainsVersions.map {
            Domain(domainId: $0.key, version: $0.value, translations: nil)
        }
        // set update scheme
        return UpdateTranslationsScheme(appId: configuration.appId,
                                        locale: locale,
                                        domains: domains)
    }

    // MARK: - Helpers

    private func handleWarnings(from receivedScheme: UpdateTranslationsScheme) {
        guard let listOfWarnings = receivedScheme.warnings else {
            return
        }
        listOfWarnings.forEach { Logger.log(messageFormat: $0) }
    }

    private func translations(in domain: Domain) -> [String: String]? {
        guard let translations = domain.translations else {
            return nil
        }
        return LocaleTranslations.flatTranslations(translations: translations)
    }

    private func write(translations: LocaleTranslations) -> Bool {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(translations) else {
            Logger.log(messageFormat: Constants.UpdateLocaleService.couldNotEncodeLocaleTranslations)
            return false
        }

        // !!! Logs Every error path
        return fileHandler.writeToFile(translations.locale,
                                       data: data,
                                       in: translations.domainId)
    }
}
