//
//  FinderExtensions.swift
//  Finder
//
//  Created by Simion Schiopu on 9/7/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

typealias FilePath = String

extension FilePath {
    
    func deleteSuffixes() -> FilePath {
        var modifiedString = self
        let suffixes = [DirectorySuffix.AllFiles, DirectorySuffix.Slash]
        for suffix in suffixes {
            modifiedString = modifiedString.deleteSuffix(suffix)
        }
        
        if modifiedString.hasSuffix(DirectorySuffix.AnyCombination) &&
            modifiedString.hasPrefix(DirectorySuffix.AnyCombination) {
                modifiedString = modifiedString.stringByReplacingOccurrencesOfString(DirectorySuffix.AnyCombination, withString: String.Empty)
        }
        
        return modifiedString
    }
    
    func isKindOfType(type: String) -> Bool {
        return self.hasSuffix(type)
    }
}

extension String {
    static let Empty = ""
    
    func deleteSuffix(suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        
        var modifiedString = self
        let numberOfLetters = suffix.characters.count
        for _ in 0 ..< numberOfLetters {
            modifiedString = modifiedString.substringToIndex(modifiedString.endIndex.predecessor())
        }
        
        return modifiedString
    }
    
    func hasDirectory(named name: String) -> Bool {
        return self.lowercaseString.rangeOfString(name.lowercaseString) != nil
    }
}

extension SequenceType where Generator.Element == FilePath {
    
    func keepPathsMatchingType(type: String) -> [FilePath] {
        return self.filter { $0.isKindOfType(type) }
    }
    
    func excludePathsContainingSubpath(subpath: FilePath) -> [FilePath] {
        return self.filter { !$0.hasPrefix(subpath) }
    }
    
    func excludePathsContainingSubpathsInArray(subpaths: [FilePath]) -> [FilePath] {
        var remainedPaths = self as! [FilePath]
        for subpath in subpaths {
            remainedPaths = remainedPaths.excludePathsContainingSubpath(subpath)
        }
        
        return remainedPaths
    }
    
    func excludePathsContainingDirectories(directories: [FilePath]) -> [FilePath] {
        var remainedPaths = self as! [FilePath]
        
        for directoryName in directories {
            remainedPaths = remainedPaths.filter { !$0.hasDirectory(named: directoryName) }
        }
        
        return remainedPaths
    }
    
    func deleteRootPath(rootPath: FilePath) -> [FilePath] {
        return self.map {
            $0.stringByReplacingOccurrencesOfString(rootPath, withString: FilePath.Empty)
        }
    }
    
    func deleteSuffixes() -> [FilePath] {
        return self.map { $0.deleteSuffixes() }
    }
}