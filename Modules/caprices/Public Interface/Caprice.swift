//
//  Caprice.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/1/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Printer

public let ResultDictionaryPathKey = "path"
public let ResultDictionaryTypeKey = "type"
public let ResultDictionaryExcludesKey = "excludes"
public let ResultDictionaryFileKey = "files"
public let ResultDictionaryErrorKey = "error"


public typealias Options = [String: [String]]

public struct Caprice {

    let messageProcessor = MessageProcessor()
    
    public init() { }
    
    /**
    Returns dictionary with necessary info
    (compulsory keys : "path", "type"; optional keys: "files", "excludes"),
    Retuns empty dictionary if help is requested.
    Returns current path if an error occurs.
    */
    public func processArguments(arguments: [String]) -> Options {
        let resultDictionary = messageProcessor.processArguments(arguments)
        return checkIfErrorOccursOrHelpRequested(resultDictionary)
    }
    
    
    private func checkIfErrorOccursOrHelpRequested(dictionary: Options) -> Options {
        var dictionary = dictionary
        if dictionary.isEmpty {
            printHelp()
            dictionary[ResultDictionaryPathKey] = messageProcessor.defaultDictionaryWithPathAndType()[ResultDictionaryPathKey]
        }
        if let _ = dictionary[HelpOptionKey] {
            dictionary = Options()
        }
        
        return dictionary
    }
    
    
    private func printHelp() {
        do {
            try messageProcessor.printHelp()
        } catch {
            errorPrinter.printError("\nCan't find help file")
        }
    }
    
    /**
    Returns an array with dictionaries with keys: "type" and "fileName" for reports saving.
    For xcode reporter type, value for "fileName" key will be empty.
    Must be called after processing arguments.
    */
    public func getReporters() -> [ReporterType] {
        return messageProcessor.getReporters()
    }
    
    /**
    Returns dictionary with rules and it's argument.
    Must be called after processing arguments.
    */
    public func getRuleThresholds() -> CustomizationRule {
        return messageProcessor.getRuleThresholds()
    }
    
    /**
    Returns verbosity level indicated by user or default(error).
    Must be called after processing arguments.
    */
    public func getVerbosityLevel() -> VerbosityLevel {
        return messageProcessor.getVerbosityLevel()
    }

}
