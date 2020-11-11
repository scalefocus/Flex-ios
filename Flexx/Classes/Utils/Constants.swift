//
//  Constants.swift
//
//  Created by Nadezhda Nikolova on 26.11.18.
//  Copyright © 2017 Upnetix. All rights reserved.
//

struct Constants {
    
    struct RequestErrorHandler {
        static let httpRequestError = "Network error: %@"
        static let requestResponseError = "Invalid network response"
        static let couldNotCreateUrlRequest = "Couldn't create update request object."
    }
    
    struct Localizer {
        static let emptyLocaleFileError = "File for locale %@ is empty"
        static let emptyLocaleBackupFileError = "File for locale %@ is empty when reading backup files."
        static let changedToDefaultLocale = "Locale is changed to %@. This is the default locale."
        static let changeLocaleMissingLanguageCodeError = "Change locale failed because of missing language code"
        static let errorInConfigurationInitialization = "An error occured while initializing Configuration file. Please check the provided properties in FlexxConfig.plist"
        static let errorInitializingFlex = "An error occured while initializing Flexx. Please check the provided properties in FlexxConfig.plist and try again."
        static let localeFileParsingError = "Error occured while parsing the Locale file. Translations are not updated."
        static let errorSetDefaultLocale = "Couldn't get default locale from the backend files."
        static let configurationIsNotSet = "Configuration is not set. Please check it and try again."
    }
    
    struct UpdateLocaleService {
        static let couldNotEncodeLocaleTranslations = "Couldn't encode locale translations for update service."
        static let couldNotUpdateTranslations = "Couldn't update current locale file and in memory translations"
        static let emptyTranslations = "There are no translations to be updated"
        static let currentlyUpdatingMessage = "There is an update that is currently in progress. Your update request is enqueued"
        static let missingUpdateScheme = "No scheme was provided"
        static let relativePath = "/api/localizations/v1.1/update_check"
        static let successfulUpdate = "Update is successful for %@"
        static let updateError = "Update error: %@"
        static let badState = "Update is stopped. Bad state."
        static let invalidLocale = "Locale identifier is invalid"
    }

    struct UpdateDomainsService {
        static let relativePath = "/api/domains"
    }
    
    struct FileHandler {
        static let couldNotWriteFileErrorMessage = "Couldn't save updated strings to locale file"
        static let couldNotCreateTmpFileErrorMessage = "Couldn't create or overwrite tmp file to save new strings"
        static let readingFileErrorMessage = "Error occured while reading the file. Will try to read backup file"
        static let missingLocaleFileErrorMessage = "File for locale %@ is missing"
        static let noBundleIdErrorMessage = "No bundle id was specified. Check your project file"
        static let applicationSupportDirMissingErrorMessage = "Application Support dir is missing"
        
        static let missingBackupFile = "Backup file for locale %@ is missing"
        static let jsonFileExtension = "json"
        static let plistFileExtension = "plist"
        static let localizationsPath = "Localizations"
        static let readingLocaleFileErrorMessage = "Error occured while reading %@. Will try to read backup file."
        static let readingLocaleZipFileErrorMessage = "Error occured while reading %@."
        static let zipFileVersionFileName = "project"
        static let readingBackupFileErrorMessage = "Error occured while reading backup file."
        static let readingLocaleFileNamesErrorMessage = "Error occured while reading locale file names for domain: %@."
    }

    struct FileService {
        static let directoryNotFound = "Directory not found: %@."
        static let fileNotFound = "File not found: %@."
        static let readingFile = "Can not read file %@."
        static let createTmpFile = "Can not create temp file %@"
        static let applicationSupportDirectoryNotFound = "Application Support Directory not found"

        static let tempFileNameSuffix = "_tmp"
    }
    
    struct UserDefaultKeys {
        static let zipFileVersion = "zipfile-version"
    }
    
    struct LocalesContractor {
        static let errorRequestForGetLocales = "Languages are loaded from local files. Request for getting locales failed or return empty list of languages."
        static let errorGetingLocalesFromFiles = "Languages can't be retrieved from local files."
        static let relativePath = "/api/locales"
        static let localizationsPath = "localizations"
    }
    
    struct RequestExecutor {
        static let authHeader = "X-Authorization"
        static let contentTypeHeader = "Content-Type"
        static let contentTypeValue = "application/json"
    }

    struct JSONConfigKey {
        static let projectVersion = "project_version"
    }

    struct UpdateLocalizationsWorker {
        static let encodingError = "Encoding error: %@"
        static let decodingError = "Decoding error: %@"
        static let invalidBaseUrlError = "Invalid base URL: %@."
    }

    struct ConfigurationLoader {
        static let configurationPlistFileName = "FlexxConfig"

        static let errorPlistNotFound = "An error occured while reading FlexxConfig.plist. Please check that FlexxConfig.plist is included in the target."
        static let errorInvalidContent = "An error occured while reading FlexxConfig.plist. Please check if it is a valid plist file."
    }
}
