//
//  Config.swift
//  Flexx
//
//  Created by Nadezhda on 12.08.19.
//  Copyright © 2019 Upnetix. All rights reserved.
//

/// Config is one of the files that we receive from the backend together with the translations.
/// We use this only in setValueToDefaultLocale() method.
struct Config: Decodable {
    let appId: String
    let domainId: String
    let defaultLocale: String
    let version: Int
}
