//
//  Project.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 28.09.20.
//

import Foundation

struct Project: Decodable {
    /// Last version
    let version: Int

    enum CodingKeys: String, CodingKey {
        case version = "project_version"
    }
}
