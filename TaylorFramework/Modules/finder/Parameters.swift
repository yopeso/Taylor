//
//  Arguments.swift
//  Finder
//
//  Created by Simion Schiopu on 8/28/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

struct Parameters {
    let rootPath: String
    let excludes: [String]
    let files: [String]
    let type: String
    
    private init(parameters: (path: String, excludes: [String], files: [String], type: String)) {
        rootPath = parameters.path
        excludes = parameters.excludes
        files = parameters.files
        type = parameters.type
    }
    
    init?(dictionary: Options, printer: ErrorPrinter) {
        let pathValue = dictionary[ParameterKey.Path.rawValue]
        if pathValue == nil || pathValue!.isEmpty || pathValue!.first!.isEmpty {
            printer.printWrongRootPathMessage()
            return nil
        }
        let fileType = dictionary[ParameterKey.FileType.rawValue]
        if  fileType == nil || fileType!.isEmpty || fileType!.first!.isEmpty {
            printer.printWrongTypeFile()
            return nil
        }
        let excludesValue = dictionary[ParameterKey.Excludes.rawValue] ?? []
        let filesValue = dictionary[ParameterKey.Files.rawValue] ?? []

        self.init(parameters: (pathValue!.first!, excludesValue, filesValue, fileType!.first!))
    }
}
