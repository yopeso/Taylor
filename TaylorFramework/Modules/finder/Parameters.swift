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
    
    convenience init?(dictionary: Options, printer: ErrorPrinter) {
        let pathValue = dictionary[ParametersKeys.Path]
        if pathValue == nil || pathValue!.isEmpty || pathValue!.first!.isEmpty {
            printer.printWrongRootPathMessage()
            return nil
        }
        let fileType = dictionary[ParametersKeys.FileType]
        if  fileType == nil || fileType!.isEmpty || fileType!.first!.isEmpty {
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
        self.init(parameters: (pathValue!.first!, excludesValue!, filesValue!, fileType!.first!))
    }
}
