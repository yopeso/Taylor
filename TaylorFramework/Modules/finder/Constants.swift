//
//  Constants.swift
//  Finder
//
//  Created by Simion Schiopu on 9/7/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

enum FinderError: ErrorType {
    case NotSpecifiedRootPath
    case NotSpecifiedType
    case WrongFilePath(path: String)
}

struct DirectorySuffix {
    static let AllFiles = "/*"
    static let AnyCombination = ".*"
    static let Slash = "/"
}

struct ParametersKeys {
    static let Path = "path"
    static let Excludes = "excludes"
    static let Files = "files"
    static let FileType = "type"
}