//
//  Excludes.swift
//  Finder
//
//  Created by Simion Schiopu on 9/5/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

class Excludes {
    
    let excludePaths: [FilePath]
    
    lazy var absolutePaths: [FilePath] = {
        let paths = self.excludePaths.filter { $0.hasPrefix(DirectorySuffix.Slash) }
        return paths.map { $0.substringFromIndex($0.startIndex.successor()) }
        }()
    
    lazy var relativePaths: [String] = {
        return self.excludePaths.filter { !$0.hasPrefix(DirectorySuffix.Slash) &&
            !$0.hasSuffix(DirectorySuffix.AnyCombination) &&
            !$0.hasPrefix(DirectorySuffix.AnyCombination)}
        }()
    
    init(paths: [FilePath], rootPath: FilePath) {
        self.excludePaths = paths.deleteRootPath(rootPath).deleteSuffixes()
    }
}
