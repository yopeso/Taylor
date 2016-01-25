//
//  FileOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let FileLong = "--file"
let FileShort = "-f"

struct FileOption: ExecutableOption {
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument : Path
    let name = "FileOption"
    
    init(argument:Path = String.Empty) {
        optionArgument = argument
    }
    
    
    func executeOnDictionary(inout dictionary: Options) {
        dictionary.add([optionArgument.absolutePath(analyzePath)], toKey: ResultDictionaryFileKey)
    }
    
}
