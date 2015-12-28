//
//  FinderPath.swift
//  Finder
//
//  Created by Simion Schiopu on 8/26/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

final class Finder {
    private let fileManager: NSFileManager
    private let printer: ErrorPrinter
    private var parameters: Parameters?
    private var excludes: Excludes?
    
    init(fileManager: NSFileManager = NSFileManager.defaultManager(), printer: Printer = Printer(verbosityLevel: .Error)) {
        self.fileManager = fileManager
        self.printer = ErrorPrinter(printer: printer)
    }
    
    func findFilePaths(parameters dictionary: Options) -> [String] {
        parameters = Parameters(dictionary: dictionary, printer: printer)
        guard parameters != nil && validateParameters(parameters!) else {
            return []
        }
        parameters!.rootPath.deleteSuffixes()
        excludes = Excludes(paths: parameters!.excludes, rootPath: parameters!.rootPath)
        let pathsFromDirectory = findPathsInDirectory(parameters!.rootPath)
        
        return (pathsFromDirectory + parameters!.files).unique
    }
    
    private func validateParameters(parameters: Parameters) -> Bool {
        return validatePath(parameters.rootPath) && validateFiles(parameters.files)
    }
    
    private func findPathsInDirectory(path: String) -> [String] {
        guard parameters != nil && excludes != nil else { return [] }
        do {
            let pathsInDirectory = try fileManager.subpathsOfDirectoryAtPath(path)
            let paths = exclude(excludes!, fromPaths: pathsInDirectory)
            return paths.map { absolutePath(parameters!.rootPath, fileName: $0) }
        } catch _ {
            printer.printFileManagerError(path)
            return []
        }
    }
    
    private func exclude(excludes: Excludes, fromPaths files: [FilePath]) -> [FilePath] {
        guard parameters != nil else { return [] }
        return files.keepPathsMatchingType(parameters!.type)
            .excludePathsContainingSubpathsInArray(excludes.absolutePaths)
            .excludePathsContainingDirectories(excludes.relativePaths)
    }
    
    private func validateFiles(files:[FilePath]) -> Bool {
        guard parameters != nil else { return true }
        for file in files {
            if !existsFileOfTypeAtPath(file, type: parameters!.type) {
                printer.printWrongFilePath(file)
                return false
            }
        }
        return true
    }
    
    private func existsFileOfTypeAtPath(path: FilePath, type: String) -> Bool {
        return fileManager.fileExistsAtPath(path) && path.isKindOfType(type)
    }
    
    private func validatePath(path: FilePath) -> Bool {
        if !directoryExistsAtPath(path) {
            printer.printWrongRootPathMessage()
            return false
        }
        return true
    }
    
    private func directoryExistsAtPath(path: FilePath) -> Bool {
        guard let rootPath = parameters?.rootPath else { return false }
        return fileManager.fileExistsAtPath(path) && fileManager.isDirectory(rootPath)
    }
    
    private func absolutePath(path: FilePath, fileName: String) -> FilePath {
        return path + DirectorySuffix.Slash + fileName
    }
}

extension Array where Element: Equatable {
    var unique: [Element] {
        return self.reduce([Element]()) { !$0.contains($1) ? $0 + $1 : $0 }
    }
}