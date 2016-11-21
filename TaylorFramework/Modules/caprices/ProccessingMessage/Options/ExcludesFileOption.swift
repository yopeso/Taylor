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
    var analyzePath = FileManager.default.currentDirectoryPath
    var optionArgument: Path
    let name = "ExcludesFileOption"
    
    init(argument: Path = "") {
        optionArgument = argument
    }
    
    
    func executeOnDictionary(_ dictionary: inout Options) {
        let excludesFilePath = optionArgument.absolutePath(analyzePath)
        if let excludePaths = pathsFromExcludesFile(excludesFilePath) {
            addExcludePaths(excludePaths, toDictionary: &dictionary)
        } else {
            dictionary = defaultErrorDictionary
        }
    }
    
    
    fileprivate func pathsFromExcludesFile(_ path: String) -> [String]? {
        let excludeFileReader = ExcludesFileReader()
        
        do {
            return try excludeFileReader.absolutePathsFromExcludesFile(path, forAnalyzePath: analyzePath)
        } catch CommandLineError.invalidExclude(let errorMsg) {
            errorPrinter.printError(errorMsg)
        } catch _ { }
        return nil
    }
    
    
    fileprivate func addExcludePaths(_ paths: [String], toDictionary dictionary: inout Options) {
        if paths.isEmpty { return }
        dictionary.add(paths, toKey: ResultDictionaryExcludesKey)
    }
    
}
