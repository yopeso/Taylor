//
//  MessageProcessor.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 8/26/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Cocoa

let DefaultExtensionType = "swift"
let DefaultExcludesFile = "/excludes.yml"

let FlagKey = "flag"
let FlagKeyValue = "info requested"

let errorPrinter = Printer(verbosityLevel: .Error)

/* 
If you change this class don't forget to fix his mock for actual right tests (if is case)
*/
class MessageProcessor {
    
    let optionsProcessor = OptionsProcessor()
    
    func processArguments(arguments:[String]) -> Options {
        guard arguments.count > 1 else { return defaultResultDictionary() }
        
        return processMultipleArguments(arguments)
    }
    
    
    func defaultResultDictionary() -> Options {
        var defaultDictionary = defaultDictionaryWithPathAndType()
        setDefaultExcludesIfExistsToDictionary(&defaultDictionary)
        
        return defaultDictionary
    }
    
    
    func processMultipleArguments(arguments:[String]) -> Options {
        if arguments.count.isOdd {
            return optionsProcessor.processOptions(arguments)
        } else if arguments.containFlags {
            FlagBuilder().flag(arguments.second!).execute() //Safe to force unwrap
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
    

    func setDefaultExcludesIfExistsToDictionary(inout dictionary: Options) {
        guard let pathKey = dictionary[ResultDictionaryPathKey] where !pathKey.isEmpty else {
            return
        }
        do {
            let defaultExcludesFilePath = defaultExcludesFilePathForDictionary(dictionary)
            let excludePaths = try ExcludesFileReader().absolutePathsFromExcludesFile(defaultExcludesFilePath,
                                    forAnalyzePath: pathKey.first!)
            if !excludePaths.isEmpty {
                dictionary[ResultDictionaryExcludesKey] = excludePaths
            }
        } catch {
            return
        }
    }
    

    func defaultExcludesFilePathForDictionary(dictionary: Options) -> String {
        guard let pathKey = dictionary[ResultDictionaryPathKey] where !pathKey.isEmpty else {
            return ""
        }
        return pathKey.first! + DefaultExcludesFile
    }
    
    
    func defaultDictionaryWithPathAndType() -> Options {
        return [ResultDictionaryPathKey : [NSFileManager.defaultManager().currentDirectoryPath],
                ResultDictionaryTypeKey : [DefaultExtensionType]]
    }
    
}
