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

    private var apiUrl: URL {
        URL(string:baseUrl)!
            .appendingPathComponent(Constants.UpdateLocaleService.relativePath)
    }

    private lazy var data: Data = {
        try! Data(contentsOf: stubUrl)
    }()

    private lazy var stubUrl: URL = {
        Bundle(for: UpdateLocaleServiceTests.self)
            .url(forResource: "StubUpdates", withExtension: "json")!
    }()

    private var timerService: MockTimerService!
    private var translationsStore: TranslationsStore!

    private var sut: UpdateLocaleService!

    override func setUpWithError() throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: self.apiUrl,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, self.data)
        }

        // Create URL Session Configed with our Mock Protocol
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: sessionConfig)

        // Create network worker
        let networkService = RequestExecutorImp(urlSession)
        let updateLocalizationsWorker =
            UpdateLocalizationsWorkerImp(networkService: networkService)

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
                                        defaultUpdateInterval: defaultUpdateInterval)

        // create timer service
        timerService = MockTimerService()
        // create sut
        let configuration = Configuration(baseUrl: baseUrl,
                                          secret: "Doesn't matter",
                                          appId: appId,
                                          domains: [],
                                          shaValue: "Doesn't matter")
        sut = UpdateLocaleServiceImp(configuration: configuration,
                                     timerService: timerService,
                                     storeLocalizationsWorker: storeLocalizationsWorker,
                                     updateLocalizationsWorker: updateLocalizationsWorker)

    }

    override func tearDownWithError() throws {
        // Do something
    }

    func testShouldStartUpdateService() {
        // Given
        sut.startUpdateService(locale: "en-GB")

        // When
        timerService.elapseTime()

        // Just wait 5 seconds.
        sleep(5)

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
