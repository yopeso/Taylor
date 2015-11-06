//
//  TypeOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

let TypeLong = "--type"
let TypeShort = "-t"

class TypeOption: ExecutableOption {
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument : String
    let name = "TypeOption"
    
    required init(argument:String = EmptyString) {
        optionArgument = argument
    }
    
    
    func executeOnDictionary(inout dictionary: Options) {
        dictionary[ResultDictionaryTypeKey] = [optionArgument]
    }
    
}
