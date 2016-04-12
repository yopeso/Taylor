//
//  ExcludesFileOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation
import ExcludesFileReader

let ExcludesFileLong = "--excludeFile"
let ExcludesFileShort = "-ef"

struct ExcludesFileOption: ExecutableOption {
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument : Path
    let name = "ExcludesFileOption"
    
    init(argument: Path = String.Empty) {
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
        do {
            return try ExcludesFileReader().absolutePathsFromExcludesFile(path, forAnalyzePath: analyzePath)
        } catch CommandLineError.InvalidExclude(let errorMsg) {
            errorPrinter.printError(errorMsg)
        } catch _ { }
        return nil
    }
    
    
    private func addExcludePaths(paths:[String],inout toDictionary dictionary:Options) {
        if paths.isEmpty { return }
        dictionary.add(paths, toKey: ResultDictionaryExcludesKey)
    }
    
}
