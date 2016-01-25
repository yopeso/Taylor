//
//  ExcludeOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let ExcludeLong = "--exclude"
let ExcludeShort = "-e"

struct ExcludeOption: ExecutableOption {
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument : Path
    let name = "ExcludeOption"
    
    init(argument:Path = String.Empty) {
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
