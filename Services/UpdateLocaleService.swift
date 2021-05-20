//
//  UpdateLocaleService.swift
//
//  Created by Пламен Великов on 3/14/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

public protocol UpdateLocaleService {
    func startUpdateService(locale: String)
    func stopUpdateService()
}

enum UpdateLocaleServiceError: Error {
    /// current update scheme is not set
    case missingUpdateScheme
    /// no current domains
    case missingDomains

    case badServiceState
}

// TODO: Documentation
///  This service handles update locale translations.
final class UpdateLocaleServiceImp: UpdateLocaleService {
    
    private enum ServiceState {
        case stopped
        case running
    }

    private var serviceState: ServiceState = .stopped
    private let timerService: TimerService

    private var updateScheme: UpdateTranslationsScheme?

    private var isCurrenlyUpdating: Bool = false
    private var updateTaskQueue: UniqueQueue<UpdateTranslationsScheme> = UniqueQueue()

    private let updateLocalizationsWorker: UpdateLocalizationsWorker
    private let domainsWorker: UpdateDomainsWorker
    private let storeLocalizationsWorker: StoreLocalizationsWorker

    // MARK: - Object lifecycle
    
    init(timerService: TimerService,
         storeLocalizationsWorker: StoreLocalizationsWorker,
         updateLocalizationsWorker: UpdateLocalizationsWorker,
         domainsWorker: UpdateDomainsWorker) {
        self.timerService = timerService
        self.storeLocalizationsWorker = storeLocalizationsWorker
        self.updateLocalizationsWorker = updateLocalizationsWorker
        self.domainsWorker = domainsWorker
    }

    deinit {
        stopUpdateService()
    }

    // MARK: - UpdateLocaleService
    
    func startUpdateService(locale: String) {
        // Simple protection
        guard !locale.isEmpty else {
            Logger.log(messageFormat: Constants.UpdateLocaleService.invalidLocale)
            return
        }

        setupUpdateService(locale: locale)
        guard let updateScheme = updateScheme else {
            Logger.log(messageFormat: Constants.UpdateLocaleService.missingUpdateScheme)
            return
        }

        stopUpdateTimer()

        if isCurrenlyUpdating {
            updateTaskQueue.insert(updateScheme)
            Logger.log(messageFormat: Constants.UpdateLocaleService.currentlyUpdatingMessage)
            return
        }

        startUpdateTimer()
    }

    func stopUpdateService() {
        stopUpdateTimer()
        isCurrenlyUpdating = false
        updateTaskQueue.clearAllTasks()
    }

    // MARK: - Helpers

    /// Sets update scheme
    private func setupUpdateService(locale: String) {
        updateScheme = storeLocalizationsWorker.scheme(for: locale)
    }

    private func startUpdateTimer() {
        timerService.start { [weak self] in
            self?.updateTranslations()
        }
        serviceState = .running
    }

    private func stopUpdateTimer() {
        timerService.stop()
        serviceState = .stopped
    }

    private func updateTranslations() {
        // nothing to update
        guard let scheme = updateScheme else {
            Logger.log(messageFormat: Constants.UpdateLocaleService.missingUpdateScheme)
            return
        }

        guard serviceState == .running else {
            Logger.log(messageFormat: Constants.UpdateLocaleService.badState)
            return
        }
        
        isCurrenlyUpdating = true

        // request all domains from server
        let domains = domainsWorker.get()
        // update current scheme with domains
        let newScheme = domains.applyTo(scheme)
        // request all new translations
        let localisations: Future<UpdateTranslationsScheme> =
            newScheme.requestLocaleTranslations(updateLocalizationsWorker)
        // store localisations
        let completed = localisations.updateLocaleTranslations(storeLocalizationsWorker)
        // observe result
        completed.observe { [weak self] result in
            guard let strongSelf = self else { return }
            // !!! No matter what - schedule the scheme for update
            strongSelf.setupUpdateService(locale: scheme.locale)
            strongSelf.updateFinished()
        }
    }

    private func updateFinished() {
        isCurrenlyUpdating = false
        
        guard let shemeToUpdate = updateTaskQueue.poll() else {
            return
        }
        
        if let _ = updateTaskQueue.peek() {
            // We have pending update start the task immediately
            updateTranslations()
        } else {
            // start service
            startUpdateService(locale: shemeToUpdate.locale)
        }
    }
    
}

// MARK: - Promises Extensions

private extension UpdateDomainsWorker {
    func get() -> Future<[Domain]> {
        let promise = Promise<[Domain]>()

        get { result in
            switch result {
            case .success(let domains):
                promise.resolve(with: domains)
            case .failure(let error):
                Logger.log(messageFormat: Constants.UpdateLocaleService.updateError,
                           args: [error.localizedDescription])
                promise.reject(with: error)
            }
        }

        return promise
    }
}

private extension UpdateLocalizationsWorker {
    func post(_ scheme: UpdateTranslationsScheme) -> Future<UpdateTranslationsScheme> {
        let promise = Promise<UpdateTranslationsScheme>()

        post(scheme) { result in
            switch result {
            case .success(let newScheme):
                promise.resolve(with: newScheme)
            case .failure(let error):
                Logger.log(messageFormat: Constants.UpdateLocaleService.updateError,
                           args: [error.localizedDescription])
                promise.reject(with: error)
            }
        }

        return promise
    }
}

private extension Future where Value == [Domain] {
    func applyTo(_ scheme: UpdateTranslationsScheme) -> Future<UpdateTranslationsScheme> {
        transformed { domains in
            let transformedDomains: [Domain] = domains
                .map { domain in
                    let version = scheme.domains
                        .first { $0.domainId == domain.domainId }?
                        .version ?? 0
                    return Domain(domainId: domain.domainId,
                                  version: version,
                                  translations: nil)
                }
            return UpdateTranslationsScheme(appId: scheme.appId,
                                            locale: scheme.locale,
                                            domains: transformedDomains)
        }
    }
}

private extension Future where Value == UpdateTranslationsScheme {
    func requestLocaleTranslations(_ worker: UpdateLocalizationsWorker) -> Future<UpdateTranslationsScheme> {
        chained { scheme in
            worker.post(scheme)
        }
    }

    func updateLocaleTranslations(_ worker: StoreLocalizationsWorker) -> Future<Void> {
        chained { scheme in
            let promise = Promise<Void>()

            if scheme.domains.isEmpty {
                Logger.log(messageFormat: Constants.UpdateLocaleService.emptyTranslations)
                promise.reject(with: UpdateLocaleServiceError.missingDomains)
            } else {
                DispatchQueue.global(qos: .background).async {
                    worker.store(receivedScheme: scheme)
                    promise.resolve(with: Void())
                }
            }

            return promise
        }
    }
}
