//
//  LocalesContractor.swift
//
//  Created by nikolay.prodanov on 10/31/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

class LocalesContractor: RequestExecutor {
    
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
                strongSelf.storeLocales(languages: languages)
            }
        } else {
            requestErrorHandler.handleRequestCreationError()
            completion([])
        }
    }
    
    func getStoredLocales()-> [Language] {
        if let locales = UserDefaults.standard.data(forKey: "AvailableLanguages"),
            let localesArr = try? JSONDecoder().decode([Language].self, from: locales) {
            return localesArr
        }
        
        return []
    }
    
    func getLocalesFromZip(domain: String?)-> [Language] {
        if domain != nil && !(domain?.isEmpty ?? true) {
            var languages = [Language]()
            let localeNames = LocaleFileHandler.getLocaleFileNames(domain: domain!)
            for locale in localeNames {
                let language = Language(code: locale, name: countryName(countryCode: locale) ?? "")
                languages.append(language)
            }
            return languages
        } else {
            return []
        }
    }
    
    private func countryName(countryCode: String) -> String? {
        let locale = Locale(identifier: "en_US")
        return locale.localizedString(forRegionCode: countryCode)
    }
    
    private func parseLanguagesResponse(data: Data?) -> [Language] {
        guard let data = data else { return [] }
        
        let jsonDecoder = JSONDecoder()
        let languages = try? jsonDecoder.decode([Language].self, from: data)
        
        return languages ?? []
    }
    
    private func storeLocales(languages: [Language]) {
        let allLanguages = try? JSONEncoder().encode(languages)
        UserDefaults.standard.set(allLanguages, forKey: "AvailableLanguages")
    }
}
