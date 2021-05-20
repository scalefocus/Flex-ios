//
//  UpdateLocaleServiceTests.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 29.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import XCTest
@testable import Flexx

class UpdateLocaleServiceTests: XCTestCase {

    private var baseUrl: String {
        "http://localizer.upnetix.ut"
    }

    private var appId: String {
        "dummy-app-id"
    }

//    private var apiUrl: URL {
//        URL(string:baseUrl)!
//            .appendingPathComponent(Constants.UpdateLocaleService.relativePath)
//    }

    private lazy var localizationsData: Data = {
        let url = Bundle(for: UpdateLocaleServiceTests.self)
            .url(forResource: "StubUpdates", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()

    private lazy var domainsData: Data = {
        let url = Bundle(for: UpdateLocaleServiceTests.self)
            .url(forResource: "StubDomains", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()

    private func data(for url: URL) -> Data {
        if url.absoluteString.contains(Constants.UpdateLocaleService.relativePath) {
            return localizationsData
        } else {
            return domainsData
        }
    }

    private var timerService: MockTimerService!
    private var translationsStore: TranslationsStore!

    private var sut: UpdateLocaleService!

    override func setUpWithError() throws {
        MockURLProtocol.requestHandler = { request in
            let url = request.url!
            let response = HTTPURLResponse(url: url,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            let data = self.data(for: url)
            return (response, data)
        }

        // Create URL Session Configed with our Mock Protocol
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: sessionConfig)

        // Create configuration
        let configuration = FlexConfiguration(baseUrl: baseUrl,
                                              secret: "Doesn't matter",
                                              appId: appId,
                                              domains: [],
                                              shaValue: "Doesn't matter")

        // Create network worker
        let networkService = RequestExecutorImp(urlSession)
        let updateLocalizationsWorker =
            UpdateLocalizationsWorkerImp(networkService: networkService,
                                         configuration: configuration)

        // create store worker
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")
        let fileHandler = LocaleFileHandler(settingsService,
                                            fileService,
                                            bundleService)
        // !!! It is in-memory, so IMO we don't need mock
        translationsStore = TranslationsStoreImp()
        let defaultUpdateInterval: Int = 30 // !!! Doesn't matter during UT
        let storeLocalizationsWorker =
            StoreLocalizationsWorkerImp(translationsStore: translationsStore,
                                        fileHandler: fileHandler,
                                        configuration: configuration,
                                        defaultUpdateInterval: defaultUpdateInterval)
        let updateDomainsWorker = UpdateDomainsWorkerImp(networkService: networkService,
                                                         configuration: configuration)

        // create timer service
        timerService = MockTimerService()
        // create sut

        sut = UpdateLocaleServiceImp(timerService: timerService,
                                     storeLocalizationsWorker: storeLocalizationsWorker,
                                     updateLocalizationsWorker: updateLocalizationsWorker,
                                     domainsWorker: updateDomainsWorker)

    }

    override func tearDownWithError() throws {
        // Do something
    }

    func testShouldStartUpdateService() {
        // Given
        sut.startUpdateService(locale: "en-GB")

        // When
        timerService.elapseTime()

        // Just wait 10 seconds before proceed
        sleep(10)

        // Then
        XCTAssert(timerService.isRuning, "Timer service should be running")
        let translations = translationsStore.translations(in: "Common") ?? [:]
        XCTAssertFalse(translations.isEmpty, "Translations should be updated")
    }

    func testShouldNotStartUpdateService() {
        // Given
        sut.startUpdateService(locale: "")

        // When
        timerService.elapseTime()

        // Then
        XCTAssertFalse(timerService.isRuning, "Timer service should not be running")
        let translations = translationsStore.translations(in: "Common") ?? [:]
        XCTAssert(translations.isEmpty, "Translations should not be updated")
    }

    func testStopUpdateService() {
        // Given
        sut.stopUpdateService()

        // When
        timerService.elapseTime()

        // Then
        XCTAssertFalse(timerService.isRuning, "Timer service should not be running")
        let translations = translationsStore.translations(in: "Common") ?? [:]
        XCTAssert(translations.isEmpty, "Translations should not be updated")
    }

}
