//
//  ReporterOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/9/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let ReporterLong = "--reporter"
let ReporterShort = "-r"

let JsonType = "json"
let PmdType = "pmd"
let PlainType = "plain"
let XcodeType = "xcode"

let ReporterTypeKey = "type"
let ReporterFileNameKey = "fileName"

struct ReporterOption: InformationalOption {
    
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var argumentSeparator = ":"
    var optionArgument : String
    let name = "ReporterOption"
    
    init(argument:String = "") {
        optionArgument = argument
    }
    
    func dictionaryFromArgument() -> OutputReporter {
        var reporterDictionary = OutputReporter()
        let reporterComponents = optionArgument.componentsSeparatedByString(argumentSeparator)
        reporterDictionary[ReporterTypeKey] = reporterComponents.first
        reporterDictionary[ReporterFileNameKey] = getOutputPathKey(reporterComponents)
        
        return reporterDictionary
    }
    
    private func getOutputPathKey(reporterComponents: [String]) -> String {
        if reporterComponents.first == XcodeType { return "" }
        return reporterComponents.second ?? ""
    }
    
    func validateArgumentComponents(components: [String]) throws {
        if components.isEmpty { return }
        let type = components.first!
        if components.count != 2 && type != "xcode" {
            throw CommandLineError.InvalidInformationalOption("\nReporter argument contain too many \":\" symbols")
        }
        if reporterTypeDoesNotMatchPosibleTypes(type) {
            throw CommandLineError.InvalidInformationalOption("\nInvalid reporter type was indicated")
        }
    }
    
    private func reporterTypeDoesNotMatchPosibleTypes(type: String) -> Bool {
        return ![JsonType, PmdType, PlainType, XcodeType].contains(type)
    }
    
}
