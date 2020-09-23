//
//  LocaleFileHandler.swift
//
//  Created by Пламен Великов on 3/14/17.
//  Copyright © 2017 Upnetix. All rights reserved.
//

import Foundation

struct Project: Decodable {
    /// Last version
    let version: Int

    enum CodingKeys: String, CodingKey {
        case version = "project_version"
    }
}

/// Internal class  locale file
public final class LocaleFileHandler {

    // MARK: - Default implementation

    static let `default` = LocaleFileHandler()

    // MARK: - Dependecies

    private var settingsService: SettingsService
    private let fileService: FileService
    private let bundleService: BundleService

    // MARK: - Initialization

    // This approach will allow us to inject all dependecies in the constructor
    public init(_ settings: SettingsService = SettingsServiceImpl(),
                _ fileService: FileService = FileServiceImpl(),
                _ bundleService: BundleService = BundleServiceImpl()) {
        self.settingsService = settings
        self.fileService = fileService
        self.bundleService = bundleService
    }

    // MARK: - Clone Locale Files from Bundle to Application Support Directory

    private typealias CloneAction = (([URL], URL?) -> Bool)?

    /// Makes copy of all files from bundle directory to application support directory
    /// Old name was `initialCopyOfLocaleFiles`
    public func cloneLocaleFilesFromBundleToApplicationSupportDirectory() {
        // try to read the last zip version from the file we received from backend
        let lastReadVersion = readProjectVersionFile()

        // get AppllicationSupport directory
        let localizationsDirectoryUrl = try? localeFilesDirectoryUrl()

        // get localizations
        let bundleLocalizations = localeFilesInBundle()

        // get handler to action thath should be performed
        let actionHandler = cloneAction(lastSavedVersion: settingsService.lastVersion,
                                        with: lastReadVersion)

        // call the action and check the result
        if actionHandler?(bundleLocalizations, localizationsDirectoryUrl) == true {
            // Action is completed with success. Update last version of the zip
            settingsService.lastVersion = lastReadVersion
        }
    }

    private func readProjectVersionFile() -> Int {
        let fileName = Constants.FileHandler.zipFileVersionFileName
        let configFileData = readBackupFile(fileName)
        do {
            return try parseProjectVersion(data: configFileData)
        } catch {
            Logger.log(messageFormat: "Error reading project version")
            return .invalidVersion
        }
    }

    private func parseProjectVersion(data: Data) throws -> Int {
        let jsonDecoder = JSONDecoder()
        let project = try jsonDecoder.decode(Project.self, from: data)
        return project.version
    }

    private func localeFilesInBundle() -> [URL] {
        let directory = bundleService.localizationsUrl
        let result = try? fileService.files(at: directory)
        return result ?? []
    }

    private func cloneAction(lastSavedVersion: Int,
                             with lastReadVersion: Int) -> CloneAction {
        // check for valid values
        guard lastReadVersion != .invalidVersion else {
            return nil
        }

        guard lastSavedVersion != .invalidVersion  else {
            return copyBundleFilesToLocaleDirectory
        }

        // compare
        // NOTE: It will work even if saved version is newer than readed one
        if lastSavedVersion != lastReadVersion {
            return updateLocaleFiles
        }

        return nil
    }

    /// Copy each file from bundleDirectory to localizations directory in ApplicationsSupport
    /// in order to be able to write.
    /// If our logic is correct we should be here only on the first launching of the project
    ///
    /// - Returns: returns true if everything is successfull
    private func copyBundleFilesToLocaleDirectory(bundleLocalizations: [URL],
                                                  localizationsDirectoryUrl: URL?) -> Bool {
        guard let dir = localizationsDirectoryUrl else {
            return false
        }
        // Even if one copy file fails we should return `false` in order to skip version update
        let result = bundleLocalizations
            .map { (fromUrl) in
                let toUrl = dir.appendingPathComponent(fromUrl.lastPathComponent)

                // Retruns `true` if file is copied with success. Otherwise `false`
                // !!! It will check if `fromUrl` exists and `toUrl` doesn't exists
                return fileService.copy(from: fromUrl, to: toUrl)
            }
            .reduce(true, { $0 && $1 })
        return result
    }

    /// Delete old files from applications support (we are using "remove" function here)
    /// and put the new files from bundle directory (we are using "copy" function here)
    /// With other words we are updating files
    ///
    /// - Returns: returns true if everything is successfull
    private func updateLocaleFiles(bundleLocalizations: [URL],
                                   localizationsDirectoryUrl: URL?) -> Bool {
        guard let dir = localizationsDirectoryUrl else {
            return false
        }
        // Even if one update file fails we should return `false` in order to skip version update
        let result = bundleLocalizations
            .map { (fromUrl) in
                let toUrl = dir.appendingPathComponent(fromUrl.lastPathComponent)

                _ = fileService.remove(at: toUrl)

                // Retruns `true` if file is copied with success. Otherwise `false`
                // !!! It will check if `fromUrl` exists and `toUrl` doesn't exists
                return fileService.copy(from: fromUrl, to: toUrl)
        }
        .reduce(true, { $0 && $1 })
        return result
    }

    // MARK: - Read/Write Locale File

    /**
     Locale file should be located in Library/ApplicationSupport/{BundleId}/Localizations/{CurrentDomain} directory.
     if there is something wrong with that file backup files are used - in bundle directory

     - parameter fileName: name of the locale file.
     - parameter domain: Locale domain. Default is empty string - no domain.

     - returns: Content of that file as Data
     */
    public func readLocaleFile(_ fileName: String, in domain: String = "") -> Data {
        do {
            let localizationsDirectoryUrl = try self.localeFilesDirectoryUrl()
            let localeFileUrl = self.localeFileUrl(fileName,
                                                   for: localizationsDirectoryUrl,
                                                   in: domain)
            return try fileService.read(at: localeFileUrl)
        } catch let error {
            Logger.log(messageFormat: error.localizedDescription)
            Logger.log(messageFormat: Constants.FileHandler.readingLocaleFileErrorMessage,
                       args: [fileName])

            // fallback
            return readBackupFile(fileName, in: domain)
        }
    }

    private func localeFileUrl(_ fileName: String,
                               for directory: URL,
                               in domain: String) -> URL {
        let localeFileDir = domain.isEmpty ?
            directory : directory.appendingPathComponent(domain)
        return localeFileDir
            .appendingPathComponent(fileName)
            .appendingPathExtension(Constants.FileHandler.jsonFileExtension)
    }

    /**
     Reads file from backup directory.
     - parameter fileName: name of the locale file.
     - returns: Contents of that file or empty Data in case of error
     */
    public func readBackupFile(_ fileName: String, in domain: String = "") -> Data  {
        do {
            return try readBundleFile(fileName, in: domain)
        } catch let error {
            Logger.log(messageFormat: error.localizedDescription)
            Logger.log(messageFormat: Constants.FileHandler.readingBackupFileErrorMessage,
                       args: [fileName])

            // fallback
            return Data()
        }
    }

    private func readBundleFile(_ fileName: String, in domain: String) throws -> Data {
        // we need valid path and existing file
        guard let fileUrl = bundleService.url(forLocaleFile: fileName, in: domain) else {
            throw LocaleFileHandlerError.missingBackupFile(fileName)
        }

        // try read it
        do {
            return try fileService.read(at: fileUrl)
        } catch {
            throw LocaleFileHandlerError.readingBackupFile
        }
    }

    /**
     Writes file to application directory
     - parameter fileName: name of the locale file.
     - parameter data: contents of the file.
     - parameter domain: Locale domain.
     - returns: `true` if successfull
     */
    public func writeToFile(_ fileName: String, data: Data, in domain: String) -> Bool {
        DispatchQueue.global(qos: .background).sync {
            do {
                let localizationsDirectoryUrl = try self.localeFilesDirectoryUrl()
                let localeFileUrl = self.localeFileUrl(fileName,
                                                       for: localizationsDirectoryUrl,
                                                       in: domain)
                try fileService.write(localeFileUrl, data: data)
                return true
            } catch let error {
                Logger.log(messageFormat: error.localizedDescription)
                return false
            }
        }
    }

    // MARK: - Files Names

    /// Method returns array of file names for domain name as String values
    ///
    /// - Parameter domain: domain name
    ///
    /// - returns: array of file names for domain name as String values.
    public func localeFilesNames(in domain: String) -> [String] {
        do {
            // get AppllicationSupport directory
            let localizationsDirectoryUrl = try self.localeFilesDirectoryUrl()
            // add domain if not empty
            let directory = domain.isEmpty ?
                localizationsDirectoryUrl :
                localizationsDirectoryUrl.appendingPathComponent(domain)

            let jsonFiles = try fileService.files(at: directory).filter {
                $0.pathExtension == Constants.FileHandler.jsonFileExtension
            }
            return jsonFiles.map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            Logger.log(messageFormat: error.localizedDescription)
            Logger.log(messageFormat: Constants.FileHandler.readingLocaleFileNamesErrorMessage,
                       args: [domain])
            return []
        }
    }

    /**
     Get the directory that contains all localization files. It is located in ApplicationSupportDirectory.
     - Will try to create the directory if it is missing.
     - returns: URL to that directory.
     */
    public func localeFilesDirectoryUrl() throws -> URL {
        guard let bundleId = bundleService.bundleIdentifier else {
            throw LocaleFileHandlerError.noBundleId
        }

        let localizationsDirectoryUrl = try applicationSupportDirectory()
            .appendingPathComponent(bundleId)
            .appendingPathComponent(Constants.FileHandler.localizationsPath)

        try fileService.createDirectory(localizationsDirectoryUrl)

        return localizationsDirectoryUrl
    }

    private func applicationSupportDirectory() throws -> URL {
        do {
            return try fileService.applicationSupportDirectory()
        }  catch {
            throw LocaleFileHandlerError.applicationSupportDirMissing
        }
    }

}
