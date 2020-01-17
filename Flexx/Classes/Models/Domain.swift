//
//  Domain.swift
//
//  Created by Nadezhda Nikolova on 12/20/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

///  Used only in UpdateTranslationsScheme
///  Domain that keeps translations. Every domain is unique,
///  but 2 domains can contain same translations.
struct Domain: Codable {
    /// Name of the specific domain
    let domainId: String
    /// Last version of the locale
    let version: Int
    ///    Translation strings separated in contexts.
    ///    Each context has it's own key-value pair collection.
    ///    But for mobile we are flating them up to simple key value pairs
    ///    there should be no duplicate keys.
    let translations: [String: [String: String]]?
}

extension Domain: Equatable {
    static func == (left: Domain, right: Domain) -> Bool {
        return left.domainId == right.domainId
    }
}
