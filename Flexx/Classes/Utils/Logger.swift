//
//  Logger.swift
//
//  Created by Пламен Великов on 3/14/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

// TODO: Add Protocol
final class Logger {
    
    static var enableLogging = false
    
    static func log(messageFormat: String, args: [String] = [""]) {
        guard enableLogging else { return }
        let message = String(format: messageFormat, arguments: args)
        print("Flexx: \(message)")
    }
}
