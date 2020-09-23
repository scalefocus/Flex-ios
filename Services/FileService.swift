//
//  FileService.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 18.09.20.
//

import Foundation

public enum FileServiceError: LocalizedError {
    case directoryNotFound(String)
    case fileNotFound(String)
    case readingFile(String)
    case createTmpFile(String)
    case createDirectory(String)
    case applicationSupportDirectoryNotFound

    var localizedDescription: String {
        switch self {
        case .directoryNotFound(let directory):
            return String(format: Constants.FileService.directoryNotFound, directory)
        case .fileNotFound(let fileName):
            return String(format: Constants.FileService.fileNotFound, fileName)
        case .readingFile(let fileName):
            return String(format: Constants.FileService.readingFile, fileName)
        case .createTmpFile(let fileName):
            return String(format: Constants.FileService.createTmpFile, fileName)
        case .createDirectory(let reason):
            return reason
        case .applicationSupportDirectoryNotFound:
            return Constants.FileHandler.applicationSupportDirMissingErrorMessage
        }
    }
}

public protocol FileService {
    func files(at directory: URL) throws -> [URL]

    func copy(from srcUrl: URL, to dstUrl: URL) -> Bool
    func remove(at url: URL) -> Bool

    func read(at url: URL) throws -> Data
    func write(_ fileUrl: URL, data contents: Data) throws

    func createDirectory(_ directoryUrl: URL) throws

    func applicationSupportDirectory() throws -> URL
}

public final class FileServiceImpl: FileService {

    private let fileManager: FileManager

    // This approach will allow us to mock FileManager
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    // MARK: - FileService

    /// Gets all not hidden json files found at givven directory
    public func files(at directoryUrl: URL) throws -> [URL] {
        guard !fileManager.fileExists(atPath: directoryUrl.path) else {
            throw FileServiceError.directoryNotFound(directoryUrl.path)
        }

        return try fileManager.contentsOfDirectory(at: directoryUrl,
                                                   includingPropertiesForKeys: nil,
                                                   options: .skipsHiddenFiles)
    }

    /// Copies [safely] the item at the specified URL to a new location synchronously.
    public func copy(from srcUrl: URL, to dstUrl: URL) -> Bool {
        do {
            try fileManager.copyItem(at: srcUrl, to: dstUrl)
        } catch let error {
            // TODO: Constant
            Logger.log(messageFormat: "Error in copying file from path \(srcUrl.path) to \(dstUrl.path). \(error.localizedDescription)")
            return false
        }
        return true
    }

    /// Removes [safely] the locale file at the specified URL.
    public func remove(at url: URL) -> Bool {
        do {
            try fileManager.removeItem(at: url)
        } catch let error {
            // TODO: Constant
            Logger.log(messageFormat: "Error in removing file at url \(url).\(error.localizedDescription)")
            return false
        }
        return true
    }

    /**
    Reads file from directory 
    - parameter fileName: name of the locale file.
    - returns: Contents of that file or empty Data in case of error
    */
    public func read(at url: URL) throws -> Data {
        // Check if locale file exists
        guard fileManager.fileExists(atPath: url.path) else {
            throw FileServiceError.fileNotFound(fileNameFromUrl(url))
        }

        // try read it
        guard let fileContents = fileManager.contents(atPath: url.path) else {
            throw FileServiceError.readingFile(fileNameFromUrl(url))
        }

        return fileContents
    }

    /**
     Creates a file with the specified content at the given location.
     - parameter fileName: name of the locale file.
     - parameter data: contents of the file.
     */
    public func write(_ fileUrl: URL, data contents: Data) throws {
        // ??? Do we realy need temp file
        let tmpFileUrl = tempFileUrl(for: fileUrl)

        // create tmp file with data override if the file exists
        guard fileManager.createFile(atPath: tmpFileUrl.path, contents: contents) else {
            throw FileServiceError.createTmpFile(fileNameFromUrl(tmpFileUrl))
        }

        // remove file if exists
        _ = remove(at: fileUrl)

        // rename tmp file
        try fileManager.moveItem(at: tmpFileUrl, to: fileUrl)
    }

    /// Creates a directory at the specified URL.
    public func createDirectory(_ directoryUrl: URL) throws {
        guard !fileManager.fileExists(atPath: directoryUrl.path) else {
            throw FileServiceError.directoryNotFound(directoryUrl.path)
        }

        do {
            try fileManager.createDirectory(at: directoryUrl,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        } catch let error {
            throw FileServiceError.createDirectory(error.localizedDescription)
        }
    }

    /// - Returns A url to Application support directory
    public func applicationSupportDirectory() throws -> URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory,
                                    in: .userDomainMask)

        guard let directoryUrl = urls.first else {
            throw FileServiceError.applicationSupportDirectoryNotFound
        }

        return directoryUrl
    }

    // MARK: - Helpers

    private func fileNameFromUrl(_ url: URL) -> String {
        url.deletingPathExtension().lastPathComponent
    }

    private func tempFileUrl(for fileUrl: URL) -> URL {
        fileUrl
            .deletingLastPathComponent()
            .appendingPathComponent(
                fileUrl
                    .deletingPathExtension()
                    .lastPathComponent
                    .appending(Constants.FileService.tempFileNameSuffix)
            )
            .appendingPathExtension(fileUrl.pathExtension)
    }

}
