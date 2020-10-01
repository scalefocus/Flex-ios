//
//  Flexx.swift
//
//  Created by Пламен Великов on 3/2/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

// TODO: Refactor, Unit Tests
// TODO: Inject `updateService`, `translationsStore` & `networkService`
// TODO: LocaleFileHandler as property (then inject)
public class Flexx {
    
    // MARK: Public properies
    
    /// Singleton instance of Flex
    public static let shared = Flexx()
    
    /// Default locale name
    public private(set) var defaultLocaleFileName = "en-GB"
    
    // MARK: Private properies
    
    /// Current locale
    private var currentLocale: Locale = Locale.current
    
    /// Default return when we have some kind of error when trying to get string.
    private var defaultReturn: DefaultReturnBehavior = .empty
    
    /// Configuration contains all needed information for making requests.
    private var configuration: Configuration?
    
    private var updateService: UpdateLocaleService?

    private var translationsStore: TranslationsStore = TranslationsStoreImp()
    private var networkService: RequestExecutor = RequestExecutorImp()
    
    private init() { }
    
    // MARK: Public methods
    
    /// Initialization of Flexx. This method should be called as early as possible only once.
    /// For example you can call it in AppDelegate didFinishLaunchingWithOptions.
    ///
    /// - Parameters:
    ///   - locale: the current device locale.
    ///   - enableLogging: enabled if true. False by default.
    ///   - defaultLoggingReturn: desired behavior when no key found. Empty by default.
    ///   - defaultUpdateInterval: interval time to check for update in minutes.
    ///   - completed: an optional callback when initialization process has finished.
    public func initialize(locale: Locale,
                           enableLogging: Bool = false,
                           defaultLoggingReturn: DefaultReturnBehavior = .empty,
                           defaultUpdateInterval: Int = 10,
                           completed: (() -> Void)? = nil) {
        
        // Get configuration information from FlexxConfig.plist
        guard let configurationInfo = readConfigurationPlist() else {
            Logger.log(messageFormat: Constants.Localizer.errorInitializingFlex)
            completed?()
            return
        }
        
        // set value for configuration
        configuration = configurationInfo
        
        // enable or disable logger - by default it's disabled
        Logger.enableLogging = enableLogging
        
        // Return behavior when the key passed is not found
        defaultReturn = defaultLoggingReturn
        
        // Setting locale to init locale
        currentLocale = locale
        
        // Make copy for all files from bundle directory to application support directory
        DispatchQueue.global(qos: .background).sync {
            LocaleFileHandler.default
                .cloneLocaleFilesFromBundleToApplicationSupportDirectory()
        }
        
        setValueToDefaultLocale()
        handleLocaleSynchronicallyForDomains(configurationInfo.domains, locale: locale)

        let timerService =
            TimerServiceImp(repeatingInterval: .seconds(defaultUpdateInterval * 60))
        let storeLocalizationsWorker =
            StoreLocalizationsWorkerImp(translationsStore: translationsStore,
                                        fileHandler: LocaleFileHandler.default,
                                        defaultUpdateInterval: defaultUpdateInterval)
        let updateLocalizationsWorker =
            UpdateLocalizationsWorkerImp(networkService: networkService)
        updateService = UpdateLocaleServiceImp(configuration: configurationInfo,
                                               timerService: timerService,
                                               storeLocalizationsWorker: storeLocalizationsWorker,
                                               updateLocalizationsWorker: updateLocalizationsWorker)
        updateService?.startUpdateService(locale: localeFileName(locale: locale))
        
        registerForAppLifecycle()
        
        completed?()
    }

    ///  Gets current locale
    ///  - returns: Locale value representing current Locale
    public func getCurrentLocale() -> Locale {
        return currentLocale
    }
    
    /// Retreives value from a key-value collection
    /// - parameter domain: domain that holds the translations
    /// - parameter key: key of the string
    /// - returns: string value representing the value for the requested key
    /// - usage: Flexx.shared.getString(domain: "DomainName" key: "stringKey")
    public func getString(domain: String, key: String) -> String {
        guard let transaction = translationsStore.string(forKey: key, in: domain) else {
            switch defaultReturn {
            case .empty:
                return ""
            case .key:
                return key
            case .custom(let customString):
                return customString
            }
        }
        return transaction
    }
    
    /// Function which change loaded translations with those for the passed as argument Locale.
    /// This is to force reading another locale file.
    /// - parameter desiredLocale: locale instance
    /// - parameter completed: callback when change of locale is completed no matter if it was successful
    public func changeLocale(desiredLocale: Locale, completed: (() -> Void)? = nil) {
        guard let configuration = configuration,
            desiredLocale != currentLocale else {
                Logger.log(messageFormat: "Couldn't change the locale to %@", args: [localeFileName(locale: desiredLocale)])
                completed?()
                return
        }
        
        translationsStore.clearAllTranslations()
        currentLocale = desiredLocale
        
        handleLocaleSynchronicallyForDomains(configuration.domains, locale: desiredLocale)
        updateService?.startUpdateService(locale: localeFileName(locale: desiredLocale))
        
        Logger.log(messageFormat: "Locale is change to %@", args: [localeFileName(locale: currentLocale)])
        completed?()
    }
    
    /// Function that retreives available locales.
    ///
    /// - Parameter completion that returns:
    /// Array of languages of supported locales
    /// Error that describe if we have issue in getting available locales
    public func getAvailableLocales(withCompletion completion: @escaping (_ languages: [Language], _ error: String?) -> Void) {
        guard let configuration = configuration else {
            Logger.log(messageFormat: Constants.Localizer.configurationIsNotSet)
            completion([], Constants.Localizer.configurationIsNotSet)
            return
        }

        let localesContractor = LocalesContractorImp(networkService: networkService,
                                                     localeFileHandler: LocaleFileHandler.default)
        
        localesContractor.localesFromServer(for: configuration) { languages in
            if languages.isEmpty {
                Logger.log(messageFormat: Constants.LocalesContractor.errorRequestForGetLocales)
                var error: String?
                let localLanguages = localesContractor.localesFromFiles(in: configuration.domains.first)
                if localLanguages.isEmpty {
                    error = Constants.LocalesContractor.errorGetingLocalesFromFiles
                }
                completion(localLanguages, error)
                return
            }
            completion(languages, nil)
        }
    }
    
    // MARK: Private methods
    
    /// Method for keep track with Application Lifecycle
    private func registerForAppLifecycle() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIScene.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    /**
     Method for keep track with Application Lifecycle and more specifically when the application will enter background.
     */
    @objc private func didEnterBackground(_ notification: Notification) {
        updateService?.stopUpdateService()
    }
    
    /**
     Method for keep track with Application Lifecycle and more specifically when the application will enter foreground.
     */
    @objc private func willEnterForeground(_ notification: Notification) {
        updateService?.startUpdateService(locale: localeFileName(locale: currentLocale))
    }
    
    /// Handle locale for all domains
    /// - Parameters:
    ///   - domains: list of domain names
    ///   - locale: current locale
    private func handleLocaleSynchronicallyForDomains(_ domains: [String], locale: Locale) {
        DispatchQueue.global(qos: .background).sync {
            for domain in domains {
                let fileName = localeFileName(locale: locale)
                handleLocale(fileName: fileName, domain: domain)
            }
        }
    }
    
    /// Read locale file that contains the transactions.
    ///
    /// First we try to read locale file, if the file is empty we try
    /// to read backup file. If backup file is empty we switch the locale
    /// to default locale and read the backup file for it.
    private func readLocaleFile(fileName: String, domain: String) -> Data {
        // !!! If locale file is not found this method will try to read
        //the corresponding "backup" file from the bundle
        var fileContent = LocaleFileHandler.default
            .readLocaleFile(fileName, in: domain)
        
        if fileContent.isEmpty {
            Logger.log(messageFormat: Constants.Localizer.emptyLocaleBackupFileError, args: [fileName])
            Logger.log(messageFormat: Constants.Localizer.changedToDefaultLocale, args: [defaultLocaleFileName])

            fileContent = LocaleFileHandler.default
                .readBackupFile(defaultLocaleFileName, in: domain)
            currentLocale = Locale(identifier: defaultLocaleFileName)
        }
        
        return fileContent
    }
    
    /// Handle Locale file parsing.
    /// Reading the locale file, which contains the translations for the current domain
    /// After that parse and store the translations
    /// - parameter fileName: Locale file name
    /// - parameter domain: Domain name
    private func handleLocale(fileName: String, domain: String) {
        // 1. Read locale file
        let localeData = readLocaleFile(fileName: fileName,
                                        domain: domain)
        
        // 2. Parse translations to Locale
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            // read data
            let localeTranslations = try decoder
                .decode(LocaleTranslations.self, from: localeData)

            // 3. Store translations for every domain in one place
            translationsStore.store(domain: localeTranslations.domainId,
                                    translations: localeTranslations.translations)
            translationsStore.store(domain: localeTranslations.domainId,
                                    version: localeTranslations.version)
        }
        catch let error {
            Logger.log(messageFormat: error.localizedDescription)
            Logger.log(messageFormat: Constants.Localizer.localeFileParsingError, args: [fileName])
        }
    }
    
    /// Try get default locale from config.json for the first domain and
    /// set value to defaultLocaleFileName.
    /// If we fail in getting default locale ->  defaultLocaleFileName remains "en-GB"
    /// This property is the same for every config.json in every domain
    private func setValueToDefaultLocale() {
        guard let configuration = configuration,
            let firstDomain = configuration.domains.first else {
                Logger.log(messageFormat: Constants.Localizer.errorSetDefaultLocale)
                return
        }
        do {
            // 1. Read locale file
            let data = LocaleFileHandler.default
                .readLocaleFile("config", // TODO: Create Constant
                                in: firstDomain)

            // 2. Parse translations to Locale
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            // read data
            let jsonData = try decoder
                .decode(Config.self, from: data)

            // 3. store default locale
            defaultLocaleFileName = jsonData.defaultLocale
        } catch let error {
            Logger.log(messageFormat: error.localizedDescription)
        }
    }
    
    /// Get the name of specific locale.
    private func localeFileName(locale: Locale) -> String {
        guard let languageCode = locale.languageCode else {
            Logger.log(messageFormat: Constants.Localizer.changeLocaleMissingLanguageCodeError)
            return defaultLocaleFileName
        }
        
        var localeFileName = languageCode
        
        if let country = locale.regionCode {
            localeFileName += "-" + country
        }
        
        return localeFileName
    }
    
    /// Read all properties from FlexxConfig.plist
    private func readConfigurationPlist() -> Configuration? {
        var configurationInfo: [String: Any]? = nil
        if let url = Bundle.main.url(forResource:"FlexxConfig", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                configurationInfo = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any]
                return createConfiguration(configurationInfo: configurationInfo)
            } catch let error {
                Logger.log(messageFormat: error.localizedDescription)
            }
        }
        Logger.log(messageFormat: Constants.Localizer.errorInConfigurationInittialization)
        return nil
    }
    
    /// Create Configuration
    private func createConfiguration(configurationInfo: [String: Any]?) -> Configuration? {
        guard let configurationInfo = configurationInfo,
            let appId = configurationInfo["AppId"] as? String,
            let shaValue = configurationInfo["ShaValue"] as? String,
            let baseUrl = configurationInfo["BaseUrl"] as? String,
            let secret = configurationInfo["Secret"] as? String,
            let domains = configurationInfo["Domains"] as? [String] else {
                Logger.log(messageFormat: Constants.Localizer.errorInConfigurationInittialization)
                return nil
        }
        
        return Configuration(baseUrl: baseUrl,
                             secret: secret,
                             appId: appId,
                             domains: domains,
                             shaValue: shaValue)
    }
}
