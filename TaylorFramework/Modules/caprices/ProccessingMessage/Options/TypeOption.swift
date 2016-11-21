//
//  TypeOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let TypeLong = "--type"
let TypeShort = "-t"

struct TypeOption: ExecutableOption {
    var analyzePath = FileManager.default.currentDirectoryPath
    var optionArgument: String
    let name = "TypeOption"
    
    init(argument: String = "") {
        optionArgument = argument
    }
    
    
    func executeOnDictionary(_ dictionary: inout Options) {
        dictionary[ResultDictionaryTypeKey] = [optionArgument]
    }
    
}
