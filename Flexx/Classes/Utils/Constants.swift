//
//  Constants.swift
//
//  Created by Nadezhda Nikolova on 26.11.18.
//  Copyright © 2017 Upnetix. All rights reserved.
//

struct Constants {
    
    struct RequestErrorHandler {
        static let httpRequestError = "Error: %@"
        static let requestResponseError = "Not http Error(Some kind of network error): %@"
        static let requestHttpResponseError = "HTTP Error: %@"
        static let couldNotCreateUrlRequest = "Couldn't create update request object."
    }
    
    struct Localizer {
        static let emptyLocaleFileError = "File for locale %@ is empty"
        static let emptyLocaleBackupFileError = "File for locale %@ is empty when reading backup files."
        static let changedToDefaultLocale = "Locale is changed to %@. This is the default locale."
        static let changeLocaleMissingLanguageCodeError = "Change locale failed because of missing language code"
        static let errorInConfigurationInittialization = "An error occured while initializing Configuration file. Please check the provided properties in Configuration.plist"
        static let errorInitializingFlex = "An error occured while initializing Flexx. Please check the provided properties in Configuration.plist and try again."
        static let localeFileParsingError = "Error occured while parsing the Locale file. Translations are not updated."
        static let errorSetDefaultLocale = "Couldn't get default locale from the backend files."
        static let configurationIsNotSet = "Configuration is not set. Please check it and try again."
    }
    
    struct UpdateLocaleService {
        static let couldNotEncodeLocaleTranslations = "Couldn't encode locale translations for update service."
        static let couldNotUpdateTranslations = "Couldn't update current locale file and in memory translations"
        static let emptyTranslations = "There are no translations to be updated"
        static let currentlyUpdatingMessage = "There is an update that is currently in progress. Your update request is enqueued"
        static let missingUpdateScheme = "Update service was not started because no scheme was provided"
        static let relativePath = "/api/localizations/v1.1/update_check"
        static let successfulUpdate = "Update is successful for %@"
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
        static let localizationsPath = "Localizations"
        static let readingLocaleFileErrorMessage = "Error occured while reading %@. Will try to read backup file."
        static let readingLocaleZipFileErrorMessage = "Error occured while reading %@."
        static let zipFileVersionFileName = "project"
        static let configFileName = "config"
    }
    
    struct UserDefaultKeys {
        static let zipFileVersion = "zipfile-version"
    }
    
    struct LocalesContractor {
        static let errorRequestForGetLocales = "Languages are loaded from User Defaults. Request for getting locales failed or return empty list of languages."
        static let relativePath = "/api/locales"
        static let localizationsPath = "localizations"
    }
    
    struct RequestExecutor {
        static let authHeader = "X-Authorization"
        static let contentTypeHeader = "Content-Type"
        static let contentTypeValue = "application/json"
    }
}
