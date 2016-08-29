//
//  VerbosityOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/11/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let VerbosityLong = "--verbosityLevel"
let VerbosityShort = "-vl"

let VerbosityLevelInfo = "info"
let VerbosityLevelWarning = "warning"
let VerbosityLevelError = "error"

struct VerbosityOption: InformationalOption {
    var isValid = Bool(false)
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument: String
    let name = "VerbosityOption"
    
    let argumentSeparator = ""
    
    init() {
        optionArgument = VerbosityLevelError
    }
    
    init(argument: Path) {
        optionArgument = argument
    }
    
    
    func verbosityLevelFromOption() -> VerbosityLevel {
        switch optionArgument {
        case VerbosityLevelInfo:
            return VerbosityLevel.Info
        case VerbosityLevelWarning:
            return VerbosityLevel.Warning
        default:
            return VerbosityLevel.Error
        }
    }
    
    func validateArgumentComponents(components: [String]) throws {
        guard let firstElement = components.first else {
            throw CommandLineError.InvalidInformationalOption("\nNo verbosity option specified")
        }
        guard [VerbosityLevelError, VerbosityLevelInfo, VerbosityLevelWarning].contains(firstElement) else {
            throw CommandLineError.InvalidInformationalOption("\nInvalid verbosity argument was indicated")
        }
    }
    
}
