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
    private var excludes: [FilePath]!
    
    init(fileManager: NSFileManager = NSFileManager.defaultManager(), printer: Printer = Printer(verbosityLevel: .Error)) {
        self.fileManager = fileManager
        self.printer = ErrorPrinter(printer: printer)
    }
    
    func findFilePaths(parameters dictionary: Options) -> [String] {
        parameters = Parameters(dictionary: dictionary, printer: printer)
        guard parameters != nil && validateParameters(parameters!) else {
            return []
        }
        parameters!.rootPath.deleteSuffix(FilePath.Separator)
        excludes = parameters!.excludes.deleteRootPath(parameters!.rootPath)
        let pathsFromDirectory = findPathsInDirectory(parameters!.rootPath)
        
        return (pathsFromDirectory + parameters!.files).unique
    }
    
    private func validateParameters(parameters: Parameters) -> Bool {
        return validatePath(parameters.rootPath) && validateFiles(parameters.files)
    }
    
    private func findPathsInDirectory(path: String) -> [String] {
        do {
            let pathsInDirectory = try fileManager.subpathsOfDirectoryAtPath(path)
            let paths = exclude(excludes, fromPaths: pathsInDirectory)
            return paths.map { absolutePath(parameters!.rootPath, fileName: $0) }
        } catch _ {
            printer.printSubpathsError(directoryPath: path)
            return []
        }
    }
    
    private func exclude(excludes: [FilePath], fromPaths files: [FilePath]) -> [FilePath] {
        return files.keepPathsMatchingType(parameters!.type)
            .excludePathsContainingSubpathsInArray(excludes)
    }
    
    private func validateFiles(files:[FilePath]) -> Bool {
        for filePath in files {
            guard fileManager.fileExistsAtPath(filePath) else {
                printer.printMissingFileError(filePath: filePath)
                return false
            }
            
            guard filePath.isKindOfType(parameters!.type) else {
                printer.printWrongFileTypeError(filePath: filePath)
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
        let rootPath = parameters!.rootPath
        return fileManager.fileExistsAtPath(path) && fileManager.isDirectory(rootPath)
    }
    
    private func absolutePath(path: FilePath, fileName: String) -> FilePath {
        return path + FilePath.Separator + fileName
    }
}

extension Array where Element: Equatable {
    var unique: [Element] {
        return self.reduce([]) { !$0.contains($1) ? $0 + $1 : $0 }
    }
}
