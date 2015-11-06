//
//  ExcludesFileOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Printer

let ExcludesFileLong = "--excludeFile"
let ExcludesFileShort = "-ef"

class ExcludesFileOption: ExecutableOption {
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument : Path
    let name = "ExcludesFileOption"
    
    required init(argument: Path = EmptyString) {
        optionArgument = argument
    }
    
    
    func executeOnDictionary(inout dictionary: Options) {
        let excludesFilePath = optionArgument.absolutePath(analyzePath)
        if let excludePaths = pathsFromExcludesFile(excludesFilePath) {
            addExcludePaths(excludePaths, toDictionary: &dictionary)
        } else {
            dictionary = defaultErrorDictionary
        }
    }
    
    
    private func pathsFromExcludesFile(path:String) -> [String]? {
        var excludePaths = [String]()
        do {
            excludePaths = try ExcludesFileReader().absolutePathsFromExcludesFile(path, forAnalyzePath: analyzePath)
        } catch CommandLineError.ExcludesFileError(let errorMsg) {
            errorPrinter.printError(errorMsg)
            return nil
        } catch { return nil }
        return excludePaths
    }
    
    
    private func addExcludePaths(paths:[String],inout toDictionary dictionary:[String : [String]]) {
        if paths.count <= 0 { return }
        dictionary[ResultDictionaryExcludesKey] = (dictionary[ResultDictionaryExcludesKey] == nil) ?
                                                                    paths :
                                                                    dictionary[ResultDictionaryExcludesKey]! + paths
    }
    
}
