//
//  LocalesContractor.swift
//
//  Created by nikolay.prodanov on 10/31/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

// TODO: Add Protocol, Refactor, Unit Tests
// TODO: Inject request executor instance, remove inherance
final class LocalesContractor: RequestExecutor {
    
    func getLocales(completion: @escaping ([Language]) -> Void) {
        
        let baseUrl = configuration.baseUrl
        let getLocalesUrl = baseUrl + Constants.LocalesContractor.relativePath + "?app_id=\(configuration.appId)"

        if let url = URL(string: getLocalesUrl) {
            self.execute(url: url, method: Method.get, data: nil) { [weak self] data in
                guard let strongSelf = self else {
                    completion([])
                    return
                }
                
                let languages = strongSelf.parseLanguagesResponse(data: data)
                completion(languages)
            }
        } else {
            requestErrorHandler.handleRequestCreationError()
            completion([])
        }
    }
    
    /// This method returns an array of languages for the current domain(Note here that all domains have the same languages)
    /// If the name of the file is not valid language code it is skipped
    /// - Parameter domain: domain name
    func getLocalesFromFiles(for domain: String?) -> [Language] {
        guard let domainName = domain,
            !domainName.isEmpty else { return [] }
        let localeNames = LocaleFileHandler.default.localeFilesNames(in: domainName)
        let languages: [Language] = localeNames.compactMap {
            guard let langName = getCountryNameWith(countryCode: $0) else { return nil }
            return Language(code: $0, name: langName)
        }
        return languages
    }
    
    /// Returns the name of the language as string
    /// - Parameter countryCode: code of language
    private func getCountryNameWith(countryCode: String) -> String? {
        let locale = Locale(identifier: "en_US")
        return locale.localizedString(forIdentifier: countryCode)
    }
    
    private func parseLanguagesResponse(data: Data?) -> [Language] {
        guard let data = data else { return [] }
        
        let jsonDecoder = JSONDecoder()
        let languages = try? jsonDecoder.decode([Language].self, from: data)
        
        return languages ?? []
    }
}
