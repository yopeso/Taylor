//
//  Arguments.swift
//  Finder
//
//  Created by Simion Schiopu on 8/28/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

class Parameters {
    var rootPath: String
    var excludes: [String]
    var files: [String]
    var type: String
    
    private init(parameters: (path: String, excludes: [String], files: [String], type: String)) {
        rootPath = parameters.path
        excludes = parameters.excludes
        files = parameters.files
        type = parameters.type
    }
    
    convenience init?(dictionary: [String: [String]], printer: ErrorPrinter) {
        let pathValue = dictionary[ParametersKeys.Path]
        if pathValue == nil || pathValue!.count <= 0 || pathValue![0].isEmpty {
            printer.printWrongRootPathMessage()
            return nil
        }
        let fileType = dictionary[ParametersKeys.FileType]
        if  fileType == nil || fileType!.count <= 0 || fileType![0].isEmpty {
            printer.printWrongTypeFile()
            return nil
        }
        var excludesValue = dictionary[ParametersKeys.Excludes]
        if excludesValue == nil {
            excludesValue = []
        }
        var filesValue = dictionary[ParametersKeys.Files]
        if filesValue == nil {
            filesValue = []
        }
        self.init(parameters: (pathValue![0], excludesValue!, filesValue!, fileType![0]))
    }
}
