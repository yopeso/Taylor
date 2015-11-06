//
//  ExcludeOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

let ExcludeLong = "--exclude"
let ExcludeShort = "-e"

class ExcludeOption: ExecutableOption {
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument : Path
    let name = "ExcludeOption"
    
    required init(argument:Path = EmptyString) {
        optionArgument = argument
    }
    
    
    func executeOnDictionary(inout dictionary: Options) {
        let excludePath = optionArgument.formattedExcludePath(analyzePath)
        if excludePath.isEmpty {
            dictionary = defaultErrorDictionary
            return
        }
        dictionary.add([excludePath], toKey: ResultDictionaryExcludesKey)
    }
    
}
