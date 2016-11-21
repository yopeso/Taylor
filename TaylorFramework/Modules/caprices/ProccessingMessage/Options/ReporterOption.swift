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
    
    var analyzePath = FileManager.default.currentDirectoryPath
    var argumentSeparator = ":"
    var optionArgument: String
    let name = "ReporterOption"
    
    init(argument: String = "") {
        optionArgument = argument
    }
    
    func dictionaryFromArgument() -> OutputReporter {
        var reporterDictionary = OutputReporter()
        let reporterComponents = optionArgument.components(separatedBy: argumentSeparator)
        reporterDictionary[ReporterTypeKey] = reporterComponents.first
        do {
            reporterDictionary[ReporterFileNameKey] = try getOutputPathKey(reporterComponents)
        } catch CommandLineError.invalidInformationalOption(let errorMessage) {
            errorPrinter.printError(errorMessage)
        } catch { }
        
        return reporterDictionary
    }
    
    fileprivate func getOutputPathKey(_ reporterComponents: [String]) throws -> String {
        guard let reporterType = reporterComponents.first , reporterType != XcodeType else { return "" }
        guard let fileName = reporterComponents.second , fileName != "" else {
            throw CommandLineError.invalidInformationalOption("\nNo file name indicated for \(reporterType) report.")
        }
        
        return fileName
    }
    
    func validateArgumentComponents(_ components: [String]) throws {
        if components.isEmpty { return }
        let type = components.first!
        if components.count != 2 && type != "xcode" {
            throw CommandLineError.invalidInformationalOption("\nReporter argument contain too \(components.count > 2 ? "many" : "few") \":\" symbols")
        }
        if reporterTypeDoesNotMatchPosibleTypes(type) {
            throw CommandLineError.invalidInformationalOption("\nInvalid reporter type was indicated")
        }
    }
    
    fileprivate func reporterTypeDoesNotMatchPosibleTypes(_ type: String) -> Bool {
        return ![JsonType, PmdType, PlainType, XcodeType].contains(type)
    }
    
}
