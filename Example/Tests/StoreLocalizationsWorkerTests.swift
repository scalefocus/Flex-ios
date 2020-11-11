//
//  StoreLocalizationsWorkerTests.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 30.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import XCTest
@testable import Flexx

class StoreLocalizationsWorkerTests: XCTestCase {

    private var translationsStore: TranslationsStore!
    private var fileHandler: LocaleFileHandler!
    private var fileService: MockFileServiceImp!

    // !!! Value doesn't matter during UT
    private let defaultUpdateInterval: Int = 30
    private let appId: String = "dummy-app-id"

    private var sut: StoreLocalizationsWorker!

    override func setUpWithError() throws {
        // !!! It is in-memory, so IMO we don't need mock
        translationsStore = TranslationsStoreImp()

        let settingsService = MockSettingsServiceImp()
        fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")
        fileHandler = LocaleFileHandler(settingsService,
                                        fileService,
                                        bundleService)

        // Create configuration
        let configuration = FlexConfiguration(baseUrl: "http://localizer.upnetix.ut",
                                              secret: "Doesn't matter",
                                              appId: appId,
                                              domains: [],
                                              shaValue: "Doesn't matter")

        sut = StoreLocalizationsWorkerImp(translationsStore: translationsStore,
                                          fileHandler: fileHandler,
                                          configuration: configuration,
                                          defaultUpdateInterval: defaultUpdateInterval)
    }

    override func tearDownWithError() throws {
        // Do something
    }

    func testShouldStoreScheme() {
        // Given
        let url = Bundle(for: StoreLocalizationsWorkerTests.self)
            .url(forResource: "StubUpdates", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let scheme = try! decoder.decode(UpdateTranslationsScheme.self, from: data)

        // When
        sut.store(receivedScheme: scheme)

        // Then
        XCTAssert(fileService.isWriteFileCalled,
                  "Store should persist updates on disk")
        XCTAssertEqual(translationsStore.allDomainsVersions()["Common"],
                       1597407235051,
                       "Store should cache updates in memory")
        XCTAssertEqual(translationsStore.string(forKey: "name", in: "Common"),
                       "name-enGB1",
                       "Store should cache updates in memory")
    }

    func testShouldNotStoreSchemeWithoutDomains() {
        // Given
        let scheme = UpdateTranslationsScheme(appId: appId,
                                              locale: "en-GB",
                                              domains: [])

        // When
        sut.store(receivedScheme: scheme)

        // Then
        XCTAssertFalse(fileService.isWriteFileCalled,
                  "Store should not persist any updates on disk")
        XCTAssertNil(translationsStore.allDomainsVersions()["Common"],
                       "Store should not cache aby updates in memory")
        XCTAssertNil(translationsStore.string(forKey: "name", in: "Common"),
                       "Store should not cache any updates in memory")
    }

    func testShouldNotStoreSchemeWithoutNewTranslation() {
        // Given
        let domain = Domain(domainId: "Common",
                            version: 1597407235051,
                            translations: [:])
        let scheme = UpdateTranslationsScheme(appId: appId,
                                              locale: "en-GB",
                                              domains: [domain])

        // When
        sut.store(receivedScheme: scheme)

        // Then
        XCTAssertFalse(fileService.isWriteFileCalled,
                       "Store should not persist any updates on disk")
        XCTAssertNil(translationsStore.allDomainsVersions()["Common"],
                     "Store should not cache aby updates in memory")
        XCTAssertNil(translationsStore.string(forKey: "name", in: "Common"),
                     "Store should not cache any updates in memory")
    }

    func testShouldCreateNewScheme() {
        // Given
        let locale = "en-GB"
        translationsStore.store(domain: "Common", version: 1597407235051)

        // When
        let scheme = sut.scheme(for: locale)

        // Then
        XCTAssertEqual(scheme.domains.first!.version,
                       1597407235051,
                       "Scheme should contain store domains")
        XCTAssertEqual(scheme.appId,
                       appId,
                       "Scheme should have configuration appId")
        XCTAssertEqual(scheme.locale,
                       locale,
                       "Scheme should have passed locale")
    }

}
