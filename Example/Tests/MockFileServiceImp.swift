//
//  MockFileServiceImp.swift
//  UpnetixLocalizerDemo
//
//  Created by Aleksandar Sergeev Petrov on 23.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import Foundation
@testable import Flexx

final class MockFileServiceImp: FileService {

    static let projectVersion: Int = 73
    static let bundleFiles = ["bg.json", "en-GB.json"]
    static let projectFileName = "project"
    static let localeFile = "bg-test"

    private var _createdDirectoryUrl: URL?
    var createdDirectory: URL? {
        _createdDirectoryUrl
    }

    typealias FileUrls = (srcUrl: URL, dstUrl: URL)

    private var _copiedFiles: [FileUrls] = []
    var copiedFiles: [FileUrls] {
        _copiedFiles
    }

    private var _removedFiles: [URL] = []
    var removedFiles: [URL] {
        _removedFiles
    }

    private var _writedFiles: [URL] = []
    var writedFiles: [URL] {
        _writedFiles
    }

    var isWriteFileCalled: Bool {
        !_writedFiles.isEmpty
    }

    private var _bundleFileCalls = 0

    func files(at directory: URL) throws -> [URL] {
        MockFileServiceImp.bundleFiles.map { directory.appendingPathComponent($0) }
    }

    func copy(from srcUrl: URL, to dstUrl: URL) -> Bool {
        _copiedFiles.append(FileUrls(srcUrl: srcUrl, dstUrl: dstUrl))
        return true
    }

    func remove(at url: URL) -> Bool {
        _removedFiles.append(url)
        return true
    }

    func read(at url: URL) throws -> Data {
        let fileName = url
            .deletingPathExtension()
            .lastPathComponent
        switch fileName {
        case MockFileServiceImp.projectFileName:
            // !!! Force unwrap
            return "{\"project_version\":\(MockFileServiceImp.projectVersion)}"
                .data(using: .utf8)!
        case MockFileServiceImp.localeFile:
            // !!! Force unwrap
            return "Success".data(using: .utf8)!
        case MockBundleServiceImp.bundleFile:
            if _bundleFileCalls == 0 {
                _bundleFileCalls += 1
                throw FileServiceError.fileNotFound(MockBundleServiceImp.bundleFile)
            } else {
                // !!! Force unwrap
                return "Success".data(using: .utf8)!
            }
        default:
            return Data()
        }
    }

    func write(_ fileUrl: URL, data contents: Data) throws {
        _writedFiles.append(fileUrl)
    }

    func createDirectory(_ directoryUrl: URL) throws {
        _createdDirectoryUrl = directoryUrl
    }

    func applicationSupportDirectory() throws -> URL {
        URL(fileURLWithPath: "Test/Library/Application Support/", isDirectory: true)
    }
}
