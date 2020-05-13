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
            }
        } else {
            requestErrorHandler.handleRequestCreationError()
            completion([])
        }
    }
    
    func getLocalesFromZipWith(domain: String) -> [Language] {
        var languages: [Language] = []
        if !domain.isEmpty {
            let localeNames = LocaleFileHandler.getLocaleFileNames(domain: domain)
            for locale in localeNames {
                //don't create Language if name is not available
                if let name = getCountryNameWith(countryCode: locale) {
                    let language = Language(code: locale, name: name)
                    languages.append(language)
                }
            }
        }
        return languages
    }
    
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
