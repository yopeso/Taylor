//
//  FinderPath.swift
//  Finder
//
//  Created by Simion Schiopu on 8/26/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation
import Printer

public class Finder {
    private let fileManager: NSFileManager
    private let printer: ErrorPrinter
    private var parameters: Parameters!
    private var excludes: Excludes!
    
    public init(fileManager: NSFileManager = NSFileManager.defaultManager(), printer: Printer = Printer(verbosityLevel: .Error)) {
        self.fileManager = fileManager
        self.printer = ErrorPrinter(printer: printer)
    }
    
    public func findFilePaths(parameters dictionary: [String: [String]]) -> [String] {
        parameters = Parameters(dictionary: dictionary, printer: printer)
        guard parameters != nil && validateParameters(parameters) else {
            return []
        }
        parameters.rootPath.deleteSuffixes()
        excludes = Excludes(paths: parameters.excludes, rootPath: parameters.rootPath)
        let pathsFromDirectory = findPathsInDirectory(parameters.rootPath)
        
        return removeDuplicatedPaths(pathsFromDirectory + parameters.files)
    }
    
    private func validateParameters(parameters: Parameters) -> Bool {
        return validatePath(parameters.rootPath) && validateFiles(parameters.files)
    }
    
    private func findPathsInDirectory(path: String) -> [String] {
        do {
            let pathsInDirectory = try fileManager.subpathsOfDirectoryAtPath(path)
            let paths = exclude(excludes, fromPaths: pathsInDirectory)
            return paths.map { absolutePath(parameters.rootPath, fileName: $0) }
        } catch {
            printer.printFileManagerError(path)
        }
        
        return []
    }
    
    private func exclude(excludes: Excludes, fromPaths files: [FilePath]) -> [FilePath] {
        return files.keepPathsMatchingType(parameters.type)
            .excludePathsContainingSubpathsInArray(excludes.absolutePaths)
            .excludePathsContainingDirectories(excludes.relativePaths)
    }
    
    private func validateFiles(files:[FilePath]) -> Bool {
        for file in files {
            if !existsFileOfTypeAtPath(file, type: parameters.type) {
                printer.printWrongFilePath(file)
                return false
            }
        }
        return true
    }
    
    private func existsFileOfTypeAtPath(path: FilePath, type: String) -> Bool {
        return fileExistsAtPath(path) && path.isKindOfType(type)
    }
    
    private func removeDuplicatedPaths(paths: [FilePath]) -> [FilePath] {
        return Array(Set(paths))
    }
    
    private func validatePath(path: FilePath) -> Bool {
        if !directoryExistsAtPath(path) {
            printer.printWrongRootPathMessage()
            return false
        }
        return true
    }
    
    private func directoryExistsAtPath(path: FilePath) -> Bool {
        return fileExistsAtPath(path) && isDirectoryAtPath(parameters.rootPath)
    }
    
    private func fileExistsAtPath(path: FilePath) -> Bool {
        return fileManager.fileExistsAtPath(path)
    }
    
    private func isDirectoryAtPath(path: FilePath) -> Bool {
        var isDirectory = ObjCBool(false)
        fileManager.fileExistsAtPath(path, isDirectory: &isDirectory)
        
        return isDirectory.boolValue
    }
    
    private func absolutePath(path: FilePath, fileName: String) -> FilePath {
        return path + DirectorySuffix.Slash + fileName
    }
}
