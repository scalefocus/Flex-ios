//
//  UpdateLocalizationsWorker.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 28.09.20.
//

import Foundation

/// Represents Errors that may occure during the update
enum UpdateLocalizationsError: LocalizedError {
    /// can not encode request data
    case encoding(String)
    /// can not decode server response
    case decoding(String)
    /// can not find data in the response
    case missingData
    /// can not build endpoint url - configuration base Url is invalid
    case invalidUrl(String)

    // MARK: - LocalizedError

    var localizedDescription: String {
        switch self {
        case .encoding(let reason):
            return String(format: Constants.UpdateLocalizationsWorker.encodingError, reason)
        case .decoding(let reason):
            return String(format: Constants.UpdateLocalizationsWorker.decodingError, reason)
        case .missingData:
            return Constants.RequestErrorHandler.requestResponseError
        case .invalidUrl(let baseUrl):
            return String(format: Constants.UpdateLocalizationsWorker.invalidBaseUrlError, baseUrl)

        }
    }
}

/// Represents either a success or a failure, including an associated value in each case.
enum UpdateLocalizationsResult {
    case success(UpdateTranslationsScheme)
    case failure(UpdateLocalizationsError)
}

typealias UpdateLocalizationsResultHandler = (UpdateLocalizationsResult) -> Void

protocol UpdateLocalizationsWorker {
    func post(_ scheme: UpdateTranslationsScheme,
              completion: @escaping UpdateLocalizationsResultHandler)
}

/// Helper class that requests new data from the server
final class UpdateLocalizationsWorkerImp: UpdateLocalizationsWorker {

    // MARK: - Dependencies

    private var networkService: RequestExecutor
    private var configuration: FlexConfiguration

    // MARK: - Object Lifecycle

    /// Initializes an UpdateLocalizationsWorkerImp with given request executor and configuration
    ///
    /// - Parameters:
    ///     - networkService:           Network requests executor
    ///     - configuration:            Project specific configuration
    init(networkService: RequestExecutor, configuration: FlexConfiguration) {
        self.networkService = networkService
        self.configuration = configuration
    }

    // MARK: - UpdateLocalizationsWorker

    /// Request updated translations from the server
    ///
    /// - parameter scheme:         The object that should be encoded
    /// - parameter completion:     The completion handler to call when the work is complete
    func post(_ scheme: UpdateTranslationsScheme,
              completion: @escaping UpdateLocalizationsResultHandler) {
        guard let url = updateLocalizationsEnpointUrl(for: configuration) else {
            completion(.failure(.invalidUrl(configuration.baseUrl)))
            return
        }

        // encode body data for the request
        do {
            let data = try encodeTranslationsScheme(scheme)

            networkService.execute(url: url,
                                   method: Method.post,
                                   token: configuration.shaValue,
                                   data: data) { [weak self] data in
                guard let data = data else {
                    completion(.failure(.missingData))
                    return
                }

                // decode the data returned from the server
                self?.decodeTranslationsScheme(data: data, completion: completion)
            }
        } catch {
            completion(.failure(.encoding(error.localizedDescription)))
            return
        }
    }

    // MARK: - Helpers

    /// Encode `UpdateTranslationsScheme` object into JSON Data
    ///
    /// - parameter scheme: The object that should be encoded
    ///
    /// - Returns The Encoded Data
    private func encodeTranslationsScheme(_ scheme: UpdateTranslationsScheme) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(scheme)
    }

    /// Decode JSON Data into `UpdateTranslationsScheme` object
    ///
    /// - parameter data:       The data that should be decoded
    /// - parameter completion: The completion handler to call when the work is complete
    private func decodeTranslationsScheme(data: Data,
                                          completion: @escaping UpdateLocalizationsResultHandler) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let scheme = try decoder.decode(UpdateTranslationsScheme.self, from: data)
            completion(.success(scheme))
        } catch {
            completion(.failure(.decoding(error.localizedDescription)))
        }
    }

    /// Builds Service Endpoint URL
    ///
    /// - parameter configuration:  The current configuration
    ///
    /// - Returns The endpoint Url, or nil if some error ocures
    private func updateLocalizationsEnpointUrl(for configuration: FlexConfiguration) -> URL? {
        URL(string: configuration.baseUrl)?
            .appendingPathComponent(Constants.UpdateLocaleService.relativePath)
    }

}
