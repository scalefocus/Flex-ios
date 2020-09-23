//
//  LocaleFileHandlerTests.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 8.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import XCTest
@testable import Flexx

class LocaleFileHandlerTests: XCTestCase {

    override func setUpWithError() throws {
        // Do something
    }

    override func tearDownWithError() throws {
        // Do something
    }

    func testCopyLocaleFilesFromBundleToApplicationSupportDirectory() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        // When
        sut.cloneLocaleFilesFromBundleToApplicationSupportDirectory()

        // Then
        // expect copy action to be selected (remove is not called)
        XCTAssert(fileService.copiedFiles.count == MockFileServiceImp.bundleFiles.count,
                  "The number of copied files should match bundled files")
        XCTAssert(fileService.removedFiles.count == 0,
                  "The number of removed files should be 0")

        // expect version in UserDefaults to be updated
        XCTAssertEqual(settingsService.lastVersion,
                       MockFileServiceImp.projectVersion,
                       "Settings version should match project version")
    }

    func testUpdateLocaleFilesFromBundleToApplicationSupportDirectory() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)
        
        settingsService.lastVersion = 70 // Some number smaller than projectVersion

        // When
        sut.cloneLocaleFilesFromBundleToApplicationSupportDirectory()

        // Then
        // expect update action to be selected (copy and removed to be called for every file)
        XCTAssert(fileService.copiedFiles.count == MockFileServiceImp.bundleFiles.count,
                  "The number of copied files should match bundled files")
        XCTAssert(fileService.removedFiles.count == MockFileServiceImp.bundleFiles.count,
                  "The number of removed files should match bundled files")

        // expect version in UserDefaults to be updated
        XCTAssertEqual(settingsService.lastVersion,
                       MockFileServiceImp.projectVersion,
                       "Settings version should match project version")
    }

    func testLocaleFilesAreMatchingBundleFiles() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        settingsService.lastVersion = MockFileServiceImp.projectVersion
        // When
        sut.cloneLocaleFilesFromBundleToApplicationSupportDirectory()

        // Then
        // expect no action to be selected
        XCTAssert(fileService.copiedFiles.count == 0,
                  "The number of copied files should be 0")
        XCTAssert(fileService.removedFiles.count == 0,
                  "The number of removed files should be 0")

        // expect version in UserDefaults remain the same
        XCTAssertEqual(settingsService.lastVersion,
                       MockFileServiceImp.projectVersion,
                       "Settings version should match project version")
    }

    func testReadLocaleFile() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        // When
        let data = sut.readLocaleFile(MockFileServiceImp.localeFile,
                                      in: "TestDomain")

        // Then
        // expect some data
        XCTAssert(data.count > 0, "Should return some data")
    }

    func testReadLocaleFileFallback() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        // When
        let data = sut.readLocaleFile(MockBundleServiceImp.bundleFile,
                                      in: "TestDomain")

        // Then
        // expect some data
        XCTAssert(data.count > 0, "Should return some data")
    }

    func testReadLocaleFileFails() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        // When
        let data = sut.readLocaleFile("dummy-name", in: "TestDomain")

        // Then
        // expect some data
        XCTAssert(data.count == 0, "Should return empty data object")
    }

    func testReadBackupFileFallback() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        // When
        let data = sut.readBackupFile(MockFileServiceImp.localeFile,
                                      in: "TestDomain")

        // Then
        // expect some data
        XCTAssert(data.count > 0, "Should return some data")
    }

    func testWriteToFile() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        // When
        let result = sut.writeToFile(MockFileServiceImp.localeFile,
                                     data: Data(),
                                     in: "TestDomain")

        // Then
        // expect success
        XCTAssert(result, "Should complete with success")

        XCTAssert(fileService.isWriteFileCalled,
                  "Should call File service's `write` method")
    }

    func testLocaleFilesNames() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        // When
        let result = sut.localeFilesNames(in: "")

        // Then
        XCTAssert(result.contains("bg"), "Should contain `bg` file name")
        XCTAssert(result.contains("en-GB"), "Should contain `en-GB` file name")
    }

    func testLocaleFilesDirectoryUrl() {
        // Given
        let settingsService = MockSettingsServiceImp()
        let fileService = MockFileServiceImp()
        let bundleService = MockBundleServiceImp(bundleId: "com.upnetix.flexx.ut")

        let sut = LocaleFileHandler(settingsService, fileService, bundleService)

        let expectedPath =
            "/Test/Library/Application Support/com.upnetix.flexx.ut/Localizations"

        // When
        // !!! Force unwrap
        let directoryPath = try! sut.localeFilesDirectoryUrl().path

        // Then
        XCTAssertEqual(directoryPath,
                       expectedPath,
                       "Locale Files Directory URL should match expected")
        // !!! Force unwrap
        XCTAssertEqual(fileService.createdDirectory!.path,
                       directoryPath,
                       "Locale Files Directory method should call create directory")
    }

}
