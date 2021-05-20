//
//  UpdateLocalizationsWorker.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 28.09.20.
//

import Foundation

typealias UpdateTranslationsHandler = (UpdateTranslationsScheme?) -> Void

protocol UpdateLocalizationsWorker {
    func updateTranslationsRequest(_ scheme: UpdateTranslationsScheme?,
                                   for configuration: Configuration,
                                   completion: @escaping UpdateTranslationsHandler)
}

final class UpdateLocaleWorkerImp: UpdateLocalizationsWorker {

    private var networkService: RequestExecutor

    init(networkService: RequestExecutor) {
        self.networkService = networkService
    }

    // MARK: - UpdateLocalizationsWorker

    /// Request updated translations from the server
    func updateTranslationsRequest(_ scheme: UpdateTranslationsScheme?,
                                   for configuration: Configuration,
                                   completion: @escaping UpdateTranslationsHandler) {
        guard let scheme = scheme, let url = updateLocaleServiceUrl(for: configuration) else {
            Logger.log(messageFormat: Constants.RequestErrorHandler.couldNotCreateUrlRequest)
            // TODO: completion
            return
        }

        guard let dataForPostRequest = encodeTranslationsScheme(scheme) else {
            // TODO: completion
            return
        }

        networkService.execute(url: url,
                               method: Method.post,
                               token: configuration.shaValue,
                               data: dataForPostRequest) { [weak self] data in
            let scheme = self?.decodeTranslationsScheme(data: data)
            completion(scheme)
        }
    }

    // MARK: - Helpers

    private func encodeTranslationsScheme(_ scheme: UpdateTranslationsScheme) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            return try encoder.encode(scheme)
        } catch {
            Logger.log(messageFormat: error.localizedDescription)
            return nil
        }
    }

    private func decodeTranslationsScheme(data: Data?) -> UpdateTranslationsScheme? {
        guard let data = data else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(UpdateTranslationsScheme.self, from: data)
        } catch {
            Logger.log(messageFormat: error.localizedDescription)
            return nil
        }
    }

    private func updateLocaleServiceUrl(for configuration: Configuration) -> URL? {
        URL(string: configuration.baseUrl)?
            .appendingPathComponent(Constants.UpdateLocaleService.relativePath)
    }

}


//enum UpdateLocaleTranslationError: Error {
//    /// UpdateLocaleWorkerImp was deallocated
//    case deallocated
//    /// Can not decode the received scheme
//    case decoding
//    /// Can not find new translations for the domain
//    case missingTranslations
//    /// Error while persisting translations
//    case writing
//}
//
//enum UpdateLocaleTranslationsResult {
//    case success
//    case failure(error: UpdateLocaleTranslationError)
//}
//
//typealias UpdateLocaleTranslationsHandler = (UpdateLocaleTranslationsResult) -> Void
//
//protocol UpdateLocaleWorker {
//    func updateTranslationsRequest(_ scheme: UpdateTranslationsScheme?,
//                                   for configuration: Configuration,
//                                   completion: @escaping UpdateLocaleTranslationsHandler)
//}
//
//final class UpdateLocaleWorkerImp: UpdateLocaleWorker {
//
//    private let networkService: RequestExecutor
//    private let translationsStore: TranslationsStore
//    private let fileHandler: LocaleFileHandler
//
//    init(networkService: RequestExecutor,
//         translationsStore: TranslationsStore,
//         fileHandler: LocaleFileHandler) {
//        self.networkService = networkService
//        self.translationsStore = translationsStore
//        self.fileHandler = fileHandler
//    }
//
//    // MARK: - UpdateLocaleWorker
//
//    func updateTranslationsRequest(_ scheme: UpdateTranslationsScheme?,
//                                   for configuration: Configuration,
//                                   completion: @escaping UpdateLocaleTranslationsHandler) {
//        guard let scheme = scheme, let url = updateLocaleServiceUrl(for: configuration) else {
//            Logger.log(messageFormat: Constants.RequestErrorHandler.couldNotCreateUrlRequest)
//            return
//        }
//
//        guard let dataForPostRequest = encodeTranslationsScheme(scheme) else {
//            return
//        }
//
//        networkService.execute(url: url,
//                               method: Method.post,
//                               token: configuration.shaValue,
//                               data: dataForPostRequest) { [weak self] data in
//            guard let strongSelf = self else {
//                completion(.failure(error: .deallocated))
//                return
//            }
//            guard let scheme = strongSelf.decodeTranslationsScheme(data: data) else {
//                completion(.failure(error: .decoding))
//                return
//            }
//            let result = strongSelf.updateLocaleTranslations(from: scheme)
//            completion(result)
//        }
//    }
//
//    // MARK: - Helpers
//
//    private func encodeTranslationsScheme(_ scheme: UpdateTranslationsScheme) -> Data? {
//        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//
//        do {
//            return try encoder.encode(scheme)
//        } catch {
//            Logger.log(messageFormat: error.localizedDescription)
//            return nil
//        }
//    }
//
//    private func decodeTranslationsScheme(data: Data?) -> UpdateTranslationsScheme? {
//        guard let data = data else {
//            return nil
//        }
//
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        do {
//            return try decoder.decode(UpdateTranslationsScheme.self, from: data)
//        } catch {
//            Logger.log(messageFormat: error.localizedDescription)
//            return nil
//        }
//    }
//
//    private func updateLocaleServiceUrl(for configuration: Configuration) -> URL? {
//        URL(string: configuration.baseUrl)?
//            .appendingPathComponent(Constants.UpdateLocaleService.relativePath)
//    }
//
//    private func updateLocaleTranslations(from receivedScheme: UpdateTranslationsScheme) -> UpdateLocaleTranslationsResult {
//        handleWarnings(from: receivedScheme)
//
//        for domain in receivedScheme.domains {
//            // try read and flat domain translations
//            guard let newTranslation = translations(in: domain) else {
//                return .failure(error: .missingTranslations)
//            }
//
//            // !!! Empty old translations should not be an error case
//            var oldTranslations = translationsStore.translations(in: domain.domainId) ?? [:]
//            oldTranslations.merge(dict: newTranslation)
//
//            let localeTranslations = LocaleTranslations(domainId: domain.domainId,
//                                                        appId: receivedScheme.appId,
//                                                        version: domain.version,
//                                                        locale: receivedScheme.locale,
//                                                        updateInterval: defaultUpdateInterval,
//                                                        translations: oldTranslations)
//
//            guard write(translations: localeTranslations) else {
//                return .failure(error: .writing)
//
//            }
//
//            translationsStore.store(domain: domain.domainId,
//                                    translations: oldTranslations)
//            translationsStore.store(domain: domain.domainId,
//                                    version: domain.version)
//
//            // TODO: Update Locale Scheme for every successfully stored translations
//        }
//
//        return .success
//    }
//
//    private func handleWarnings(from receivedScheme: UpdateTranslationsScheme) {
//        guard let listOfWarnings = receivedScheme.warnings else {
//            return
//        }
//        listOfWarnings.forEach { Logger.log(messageFormat: $0) }
//    }
//
//    private func translations(in domain: Domain) -> [String: String]? {
//        guard let translations = domain.translations else {
//            return nil
//        }
//        return LocaleTranslations.flatTranslations(translations: translations)
//    }
//
//    private func write(translations: LocaleTranslations) -> Bool {
//        let encoder = JSONEncoder()
//        guard let data = try? encoder.encode(translations) else {
//            Logger.log(messageFormat: Constants.UpdateLocaleService.couldNotEncodeLocaleTranslations)
//            return false
//        }
//
//        return fileHandler.writeToFile(translations.locale,
//                                       data: data,
//                                       in: translations.domainId)
//    }
//
//}
