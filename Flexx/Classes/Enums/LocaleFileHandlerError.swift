//
//  LocaleFileHandlerError.swift
//  Flexx
//
//  Created by Nadezhda on 12.08.19.
//  Copyright © 2019 Upnetix. All rights reserved.
//

import Foundation

enum LocaleFileHandlerError: LocalizedError {
    case noBundleId
    case applicationSupportDirMissing
    case couldNotCreateDirectory(String)
    case missingLocaleFile(String)
    case readingFile
    case couldNotCreateTmpFile
    case couldNotWriteFile
    
    var localizedDescription: String {
        switch self {
        case .noBundleId:
            return Constants.FileHandler.noBundleIdErrorMessage
        case .applicationSupportDirMissing:
            return Constants.FileHandler.applicationSupportDirMissingErrorMessage
        case .couldNotCreateDirectory(let reason):
            return reason
        case .missingLocaleFile(let filename):
            let errorMessage = String(format:Constants.FileHandler.missingLocaleFileErrorMessage, filename)
            return errorMessage
        case .readingFile:
            return Constants.FileHandler.readingFileErrorMessage
        case .couldNotCreateTmpFile:
            return Constants.FileHandler.couldNotCreateTmpFileErrorMessage
        case .couldNotWriteFile:
            return Constants.FileHandler.couldNotWriteFileErrorMessage
        }
    }
}
