//
//  PathOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let PathLong = "--path"
let PathShort = "-p"

struct PathOption: ExecutableOption {
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument: Path
    let name = "PathOption"
    
    init(argument:Path = EmptyString) {
        optionArgument = argument
    }
    
    
    func executeOnDictionary(inout dictionary: Options) {
        dictionary[ResultDictionaryPathKey] = [optionArgument.absolutePath()]
    }
    
}
