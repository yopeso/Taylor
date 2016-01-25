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
    static let Separator = "/"
    
    func isKindOfType(type: String) -> Bool {
        return self.hasSuffix(type)
    }
}

extension String {
    static let Empty = ""
    
    func deleteSuffix(suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        
        return (self as NSString).substringToIndex(self.characters.count - suffix.characters.count)
    }
    
    func stringByAppendingPathComponent(string: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(string)
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
        guard var remainedPaths = self as? [FilePath] else {
            return []
        }
        for subpath in subpaths {
            remainedPaths = remainedPaths.excludePathsContainingSubpath(subpath)
        }
        
        return remainedPaths
    }
    
    func deleteRootPath(rootPath: FilePath) -> [FilePath] {
        let fullRootPath = rootPath + FilePath.Separator
        return self.map {
            $0.stringByReplacingOccurrencesOfString(fullRootPath, withString: FilePath.Empty)
        }
    }
}
