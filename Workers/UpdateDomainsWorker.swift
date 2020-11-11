//
//  UpdateDomainsWorker.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 20.10.20.
//

import Foundation

/// Represents Errors that may occure during the update
enum UpdateDomainsError: LocalizedError {
    /// can not decode server response
    case decoding(String)
    /// can not find data in the response
    case missingData
    /// can not build endpoint url - configuration base Url is invalid
    case invalidUrl(String)

    // MARK: - LocalizedError

    var localizedDescription: String {
        switch self {
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
enum UpdateDomainsResult {
    case success([Domain])
    case failure(UpdateDomainsError)
}

typealias UpdateDomainsResultHandler = (UpdateDomainsResult) -> Void

protocol UpdateDomainsWorker {
    func get(_ completion: @escaping UpdateDomainsResultHandler)
}

/// Helper class that requests new data from the server
final class UpdateDomainsWorkerImp: UpdateDomainsWorker {

    // MARK: - Dependencies

    private var networkService: RequestExecutor
    private var configuration: FlexConfiguration

    // MARK: - Object Lifecycle

    /// Initializes an UpdateDomainsWorkerImp with given request executor and configuration
    ///
    /// - Parameters:
    ///     - networkService:           Network requests executor
    ///     - configuration:            Project specific configuration
    init(networkService: RequestExecutor, configuration: FlexConfiguration) {
        self.networkService = networkService
        self.configuration = configuration
    }

    // MARK: - UpdateDomainsWorker

    /// Request updated domains from the server
    ///
    /// - parameter completion:     The completion handler to call when the work is complete
    func get(_ completion: @escaping UpdateDomainsResultHandler) {
        guard let url = updateDomainsEnpointUrl(for: configuration) else {
            completion(.failure(.invalidUrl(configuration.baseUrl)))
            return
        }

        networkService.execute(url: url,
                               method: Method.get,
                               token: configuration.shaValue,
                               data: nil) { [weak self] data in
            guard let data = data else {
                completion(.failure(.missingData))
                return
            }

            // decode the data returned from the server
            do {
                let domains = (try self?.decodeDomains(from: data) ?? [])
                completion(.success(domains))
            } catch {
                completion(.failure(.decoding(error.localizedDescription)))
            }
        }
    }

    // MARK: - Helpers

    /// Builds Service Endpoint URL
    ///
    /// - parameter configuration:  The current configuration
    ///
    /// - Returns The endpoint Url, or nil if some error ocures
    private func updateDomainsEnpointUrl(for configuration: FlexConfiguration) -> URL? {
        guard var urlComponents = URLComponents(string: configuration.baseUrl) else {
            return nil
        }

        urlComponents.path = Constants.UpdateDomainsService.relativePath
        urlComponents.queryItems = [URLQueryItem(name: "app_id", value: configuration.appId)]

        return urlComponents.url
    }

    /// Decode JSON Data into array of `Domain` objects
    ///
    /// - parameter data:       The data that should be decoded
    private func decodeDomains(from data: Data) throws -> [Domain] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Domain].self, from: data)
    }
    
}
