//
//  LocaleTranslations.swift
//
//  Created by Пламен Великов on 3/9/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

// The model for the locale file we receive from the backend.
struct LocaleTranslations: Codable {
    
    /// Domain Id - we have many domains.
    /// Every one is unique, but 2 domains can contain same translations.
    let domainId: String
    
    /// The Unique Identifier of the application
    let appId: String
    
    ///Version of the locale
    var version: Int
    
    /// Locale code
    let locale: String
    
    /// Update Interval in milliseconds
    let updateInterval: Int
    
    /// Translation strings separated in contexts.
    /// Each context has it's own key-value pair collection.
    /// But for mobile we are flating them up to simple key value pairs
    /// there should be no duplicate keys.
    var translations: [String: String]
    
    init(domainId: String,
         appId: String,
         version: Int,
         locale: String,
         updateInterval: Int,
         translations: [String: String]) {
        self.domainId = domainId
        self.appId = appId
        self.version = version
        self.locale = locale
        self.updateInterval = updateInterval
        self.translations = translations
    }
    
    init(from decoder: Decoder) throws {
        let codingKeys = try decoder.container(keyedBy: CodingKeys.self)
        domainId = try codingKeys.decode(String.self, forKey: .domainId)
        appId = try codingKeys.decode(String.self, forKey: .appId)
        version = try codingKeys.decode(Int.self, forKey: .version)
        locale = try codingKeys.decode(String.self, forKey: .locale)
        updateInterval = try codingKeys.decode(Int.self, forKey: .updateInterval)
        
        /// Our translations can be of two types:
        /// [String: [String: String]] or [String: String]
        do {
            let translationsWithContext = try codingKeys
                .decode([String: [String: String]].self, forKey: .translations)
            translations = LocaleTranslations
                .flatTranslations(translations: translationsWithContext)
        } catch {
            translations = try codingKeys.decode([String: String].self, forKey: .translations)
        }
    }
    
    /// For now translations are coming from the backend as [String: [String: String]]
    /// Which represents [context: [wordKey: wordValue]]
    /// So we flat the translations - remove the context, because we don't use it
    static func flatTranslations(translations: [String: [String:String]]) -> [String: String] {
        var combinedTranslations: [String: String] = [:]
        
        translations.forEach { (_, contextTranslations) in
            contextTranslations.forEach { (key, translation) in
                combinedTranslations[key] = translation
            }
        }
        return combinedTranslations
    }
}
