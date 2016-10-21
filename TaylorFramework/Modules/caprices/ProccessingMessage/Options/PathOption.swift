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
    var analyzePath = FileManager.default.currentDirectoryPath
    var optionArgument: Path
    let name = "PathOption"
    
    init(argument: Path = "") {
        optionArgument = argument
    }
    
    
    func executeOnDictionary(_ dictionary: inout Options) {
        dictionary[ResultDictionaryPathKey] = [optionArgument.absolutePath()]
    }
    
}
