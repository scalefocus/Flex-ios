//
//  LocalesContractor.swift
//
//  Created by nikolay.prodanov on 10/31/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

// Sugar
typealias LocalesHandler = ([Language]) -> Void

// ??? Can be renamed to Worker
protocol LocalesContractor {
    func localesFromServer(for configuration: FlexConfiguration,
                           completion: @escaping LocalesHandler)
    func localesFromFiles(in domain: String?) -> [Language]
}

/// Helper class with methods that return all supported languages names either from server or from cache
final class LocalesContractorImp: LocalesContractor {

    private var networkService: RequestExecutor
    private var localeFileHandler: LocaleFileHandler

    init(networkService: RequestExecutor, localeFileHandler: LocaleFileHandler) {
        self.networkService = networkService
        self.localeFileHandler = localeFileHandler
    }

    // MARK: - LocalesContractor

    /// This method returns an array of languages from the server
    ///
    /// - parameter configuration:  project specific information
    /// - parameter completion:     The completion handler to call when the request is complete
    ///
    /// - returns:                  Array of languages
    func localesFromServer(for configuration: FlexConfiguration, completion: @escaping LocalesHandler) {
        guard let url = localesServiceUrl(for: configuration) else {
            Logger.log(messageFormat: Constants.RequestErrorHandler.couldNotCreateUrlRequest)
            completion([])
            return
        }

        networkService.execute(url: url, method: Method.get, token: configuration.shaValue, data: nil) { [weak self] data in
            guard let strongSelf = self else {
                completion([])
                return
            }

            let languages = strongSelf.parseLanguagesResponse(data: data)
            completion(languages)
        }
    }

    /// - Returns URL to the server's endpoing
    private func localesServiceUrl(for configuration: FlexConfiguration) -> URL? {
        URL(string:
                configuration.baseUrl
                + Constants.LocalesContractor.relativePath
                + "?app_id=\(configuration.appId)"
        )
    }

    /// This method returns an array of languages parsed from JSON Data Object
    ///
    /// - parameter data:  Data returned from the server
    ///
    /// - returns:                  Array of languages
    private func parseLanguagesResponse(data: Data?) -> [Language] {
        guard let data = data else { return [] }

        let jsonDecoder = JSONDecoder()
        let languages = try? jsonDecoder.decode([Language].self, from: data)

        return languages ?? []
    }
    
    /// This method returns an array of languages for the current domain(Note here that all domains have the same languages)
    /// If the name of the file is not valid language code it is skipped
    ///
    /// - parameter domain: domain name
    ///
    /// - returns: Array of languages
    func localesFromFiles(in domain: String?) -> [Language] {
        guard let domainName = domain, !domainName.isEmpty else {
            return []
        }
        let localeNames = localeFileHandler.localeFilesNames(in: domainName)
        let languages: [Language] = localeNames.compactMap {
            guard let langName = languageName(fromLocaleIdentifier: $0) else { return nil }
            return Language(code: $0, name: langName)
        }
        return languages
    }
    
    /// Returns the corresponding name (in English) of the language with the given identifier
    ///
    /// - parameter identifier: code of language
    ///
    /// - returns: The English name of the language
    private func languageName(fromLocaleIdentifier identifier: String) -> String? {
        let locale = Locale(identifier: "en_US")
        return locale.localizedString(forIdentifier: identifier)
    }

}
