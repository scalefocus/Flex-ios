//
//  UpdateLocaleService.swift
//
//  Created by Пламен Великов on 3/14/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

protocol UpdateLocaleService {
    func startUpdateService(locale: String)
    func stopUpdateService()
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

    private let configuration: Configuration

    private let updateLocalizationsWorker: UpdateLocalizationsWorker
    private let storeLocalizationsWorker: StoreLocalizationsWorker

    // MARK: - Object lifecycle
    
    init(configuration: Configuration,
         timerService: TimerService,
         storeLocalizationsWorker: StoreLocalizationsWorker,
         updateLocalizationsWorker: UpdateLocalizationsWorker) {
        self.configuration = configuration
        self.timerService = timerService
        self.storeLocalizationsWorker = storeLocalizationsWorker
        self.updateLocalizationsWorker = updateLocalizationsWorker
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
        updateScheme = storeLocalizationsWorker.scheme(locale: locale,
                                                       for: configuration)
    }

    private func startUpdateTimer() {
        timerService.start { [weak self] in
            self?.updateTranslationsRequest()
        }
        serviceState = .running
    }

    private func stopUpdateTimer() {
        timerService.stop()
        serviceState = .stopped
    }

    private func updateTranslationsRequest() {
        isCurrenlyUpdating = true

        guard let scheme = updateScheme else {
            Logger.log(messageFormat: Constants.UpdateLocaleService.missingUpdateScheme)
            return
        }

        updateLocalizationsWorker
            .post(scheme, for: configuration) { [weak self] (result) in
                guard let strongSelf = self, strongSelf.serviceState == .running else {
                    Logger.log(messageFormat: Constants.UpdateLocaleService.badState)
                    return
                }

                switch result {
                    case .success(let receivedScheme):
                        guard !receivedScheme.domains.isEmpty else {
                            Logger.log(messageFormat: Constants.UpdateLocaleService.emptyTranslations)
                            return
                        }

                        strongSelf.updateLocaleTranslations(receivedScheme: receivedScheme)
                    case .failure(let error):
                        Logger.log(messageFormat: Constants.UpdateLocaleService.updateError,
                                   args: [error.localizedDescription])
                        return
                }
            }

        updateFinished()
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
    
    private func updateLocaleTranslations(receivedScheme scheme: UpdateTranslationsScheme) {
        // OLD - Just doesn't make any sense
//        storeLocalizationsWorker.store(receivedScheme: scheme) { [weak self] in
//            // !!! can be called multiple times,
//            // once per every domain with new translations
//            self?.setupUpdateService(locale: scheme.locale)
//        }
        // NEW -  Much better IMHO
        DispatchQueue.global(qos: .background).async {
            self.storeLocalizationsWorker.store(receivedScheme: scheme)
            // !!! No matter what - schedule the scheme for update
            self.setupUpdateService(locale: scheme.locale)
        }
    }
    
}
