//
//  MessageProcessor.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 8/26/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Cocoa
import ExcludesFileReader

let DefaultExtensionType = "swift"
let DefaultExcludesFile = "/excludes.yml"

let FlagKey = "flag"
let FlagKeyValue = "info requested"

let errorPrinter = Printer(verbosityLevel: .error)

/* 
If you change this class don't forget to fix his mock for actual right tests (if is case)
*/
class MessageProcessor {
    
    let optionsProcessor = OptionsProcessor()
    
    func processArguments(_ arguments: [String]) throws -> Options {
        guard arguments.count > 1 else { return defaultResultDictionary() }
        
        return try processMultipleArguments(arguments)
    }
    
    
    func defaultResultDictionary() -> Options {
        var defaultDictionary = defaultDictionaryWithPathAndType()
        setDefaultExcludesIfExistsToDictionary(&defaultDictionary)
        
        return defaultDictionary
    }
    
    
    func processMultipleArguments(_ arguments: [String]) throws -> Options {
        if arguments.count.isOdd {
            return try optionsProcessor.processOptions(arguments: arguments)
        } else if let secondArg = arguments.second, arguments.containFlags {
            FlagBuilder().flag(secondArg).execute()
            exit(0)
        }
        errorPrinter.printError("\nInvalid options was indicated")
        return Options()
    }
    
    
    func getReporters() -> [OutputReporter] {
        return optionsProcessor.factory.reporterTypes
    }
    
    
    func getRuleThresholds() -> CustomizationRule {
        return optionsProcessor.factory.customizationRules
    }
    
    
    func getVerbosityLevel() -> VerbosityLevel {
        return optionsProcessor.factory.verbosityLevel
    }
    

    func setDefaultExcludesIfExistsToDictionary(_ dictionary: inout Options) {
        let excludeFileReader = ExcludesFileReader()
        
        guard let pathKey = dictionary[ResultDictionaryPathKey] , !pathKey.isEmpty else {
            return
        }
        do {
            let defaultExcludesFilePath = defaultExcludesFilePathForDictionary(dictionary)
            guard let firstPathKey = pathKey.first else { return }
            let excludePaths = try excludeFileReader.absolutePathsFromExcludesFile(defaultExcludesFilePath,
                                    forAnalyzePath: firstPathKey)
            if !excludePaths.isEmpty {
                dictionary[ResultDictionaryExcludesKey] = excludePaths
            }
        } catch {
            return
        }
    }
    

    func defaultExcludesFilePathForDictionary(_ dictionary: Options) -> String {
        guard let firstPathKey = dictionary[ResultDictionaryPathKey]?.first else {
            return ""
        }
        return firstPathKey + DefaultExcludesFile
    }
    
    
    func defaultDictionaryWithPathAndType() -> Options {
        return [ResultDictionaryPathKey : [FileManager.default.currentDirectoryPath],
                ResultDictionaryTypeKey : [DefaultExtensionType]]
    }
    
}
