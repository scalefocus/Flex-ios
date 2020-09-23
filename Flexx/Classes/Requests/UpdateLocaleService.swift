//
//  UpdateLocaleService.swift
//
//  Created by Пламен Великов on 3/14/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

// TODO: Add Protocol, Refactor, Unit Tests
// TODO: Inject request executor instance, remove inherance
// TODO: Move it to services
///  This service handles update locale translations at intervals.
final class UpdateLocaleService: RequestExecutor {
    
    private enum ServiceState {
        case stopped
        case running
    }
    
    private let defaultUpdateInterval: Int
    private var updateTranslationsProtocol: UpdateTranslationsProtocol
    private var updateScheme: UpdateTranslationsScheme?
    private var isCurrenlyUpdating: Bool = false
    private var serviceState: ServiceState = .stopped
    private var updateTaskQueue: UniqueQueue<UpdateTranslationsScheme> = UniqueQueue()
    private var timer: DispatchSourceTimer?
    
    init(updateTranslationsProtocol: UpdateTranslationsProtocol,
         defaultUpdateInterval: Int,
         configuration: Configuration) {
        self.updateTranslationsProtocol = updateTranslationsProtocol
        self.defaultUpdateInterval = defaultUpdateInterval
        super.init(configuration: configuration)
    }
    
    func startUpdateService(locale: String) {
        setupUpdateService(locale: locale)
        
        guard let updateScheme = updateScheme else {
            Logger.log(messageFormat: Constants.UpdateLocaleService.missingUpdateScheme)
            return
        }
        
        serviceState = .running
        stopUpdateTimer()
        
        if isCurrenlyUpdating {
            updateTaskQueue.insert(updateScheme)
            Logger.log(messageFormat: Constants.UpdateLocaleService.currentlyUpdatingMessage)
            return
        }
        
        startUpdateTimer()
    }
    
    func stopUpdateService() {
        serviceState = .stopped
        isCurrenlyUpdating = false
        updateTaskQueue.clearAllTasks()
        stopUpdateTimer()
    }
    
    private func startUpdateTimer() {
        timer = DispatchSource.makeTimerSource()
        let updateIntervalInSeconds = defaultUpdateInterval*60
        let intervalPeriod = DispatchTimeInterval.seconds(updateIntervalInSeconds)
        timer?.schedule(deadline: .now(), repeating: intervalPeriod)
        timer?.setEventHandler(handler: { [weak self] in
            self?.updateTranslationsRequest()
        })
        timer?.resume()
    }
    
    private func stopUpdateTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func updateTranslationsRequest() {
        defer {
            updateFinished()
        }
        guard let scheme = updateScheme,
            let url = URL(string: configuration.baseUrl + Constants.UpdateLocaleService.relativePath) else {
                return requestErrorHandler.handleRequestCreationError()
        }
        
        isCurrenlyUpdating = true
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let dataForPostRequest = try? encoder.encode(scheme)
        
        self.execute(url: url, method: Method.post, data: dataForPostRequest) { [weak self] data in
            guard let strongSelf = self,
                let data = data,
                strongSelf.serviceState == .running else { return }
            
            strongSelf.decodeTranslationsScheme(data: data)
        }
    }
    
    private func decodeTranslationsScheme(data: Data) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let decodedScheme = try decoder.decode(UpdateTranslationsScheme.self, from: data)
            if !decodedScheme.domains.isEmpty {
                updateLocaleTranslations(receivedScheme: decodedScheme)
            } else {
                Logger.log(messageFormat: Constants.UpdateLocaleService.emptyTranslations)
            }
        } catch {
            Logger.log(messageFormat: error.localizedDescription)
        }
        
    }
    
    private func updateFinished() {
        isCurrenlyUpdating = false
        
        guard let shemeToUpdate = updateTaskQueue.poll() else {
            return
        }
        
        if let _ = updateTaskQueue.peek() {
            // We have pending update start the task immediately
            updateTranslationsRequest()
        } else {
            // start service
            startUpdateService(locale: shemeToUpdate.locale)
        }
    }
    
    private func getLocaleTransactions(locale: String, domain: String) -> LocaleTranslations? {
        let localeData = LocaleFileHandler.default
            .readLocaleFile(locale, in: domain)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let localeTranslations = try? decoder.decode(LocaleTranslations.self,
                                                           from: localeData) else {
            return nil
        }
        return localeTranslations
    }
    
    private func setValueForTranslationsScheme(domains: [Domain], locale: String) {
        updateScheme = UpdateTranslationsScheme(appId: configuration.appId,
                                                locale: locale,
                                                domains: domains)
    }
    
    private func setupUpdateService(locale: String) {
        let domainsVersions = updateTranslationsProtocol.getDomainsVersionsInfo()
        let domains =  domainsVersions.map { Domain(domainId: $0.key,
                                                    version: $0.value,
                                                    translations: nil) }
        
        setValueForTranslationsScheme(domains: domains, locale: locale)
    }
    
    private func updateLocaleTranslations(receivedScheme: UpdateTranslationsScheme) {
        if let listOfWarnings = receivedScheme.warnings {
            listOfWarnings.forEach { Logger.log(messageFormat: $0) }
        }
        
        for domain in receivedScheme.domains {
            guard let newTranslations = domain.translations,
                var oldTranslations = updateTranslationsProtocol.getTranslationsForDomain(domain.domainId) else {
                    Logger.log(messageFormat: Constants.UpdateLocaleService.couldNotUpdateTranslations)
                    return
            }
            
            let flattedNewTranslations = LocaleTranslations.flatTranslations(translations: newTranslations)
            oldTranslations.merge(dict: flattedNewTranslations)
            
            let localeTranslations = LocaleTranslations(domainId: domain.domainId,
                                                        appId: receivedScheme.appId,
                                                        version: domain.version,
                                                        locale: receivedScheme.locale,
                                                        updateInterval: defaultUpdateInterval,
                                                        translations: oldTranslations)
            
            guard let encodedTranslationData = try? JSONEncoder().encode(localeTranslations) else {
                Logger.log(messageFormat: Constants.UpdateLocaleService.couldNotEncodeLocaleTranslations)
                Logger.log(messageFormat: Constants.UpdateLocaleService.couldNotUpdateTranslations)
                return
            }

            let success = LocaleFileHandler.default.writeToFile(receivedScheme.locale,
                                                                data: encodedTranslationData,
                                                                in: domain.domainId)

            if success {
                Logger.log(messageFormat: Constants.UpdateLocaleService.successfulUpdate, args: [receivedScheme.locale])
                updateTranslationsProtocol.didUpdateTranslations(domain: domain.domainId,
                                                                 translations: oldTranslations)
                updateTranslationsProtocol.didUpdateDomainsVersions(domain: domain.domainId,
                                                                    version: domain.version)
                setupUpdateService(locale: receivedScheme.locale)
            } else {
                Logger.log(messageFormat: Constants.UpdateLocaleService.couldNotUpdateTranslations)
            }
        }
    }
    
    deinit {
        stopUpdateService()
    }
}
