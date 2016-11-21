//
//  Constants.swift
//  Finder
//
//  Created by Simion Schiopu on 9/7/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

enum FinderError: Error {
    case wrongFilePath(path: String)
}

enum ParameterKey: String {
    case Path = "path"
    case Excludes = "excludes"
    case Files = "files"
    case FileType = "type"
}
