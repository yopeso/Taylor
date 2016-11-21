//
//  Caprice.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/1/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//


let ResultDictionaryPathKey = "path"
let ResultDictionaryTypeKey = "type"
let ResultDictionaryExcludesKey = "excludes"
let ResultDictionaryFileKey = "files"
let ResultDictionaryErrorKey = "error"


typealias Options = [String: [String]]
let ErrorKey = "error"
let ErrorDictionary = [ErrorKey: [""]]

struct Caprice {

    let messageProcessor = MessageProcessor()
    
    init() { }
    
    /**
    Returns dictionary with necessary info
    (compulsory keys : "path", "type"; optional keys: "files", "excludes"),
    Retuns empty dictionary if help is requested.
    Returns dictionary with error key if an error occurs.
    */
    func processArguments(_ arguments: [String]) throws -> Options {
        let resultDictionary = try messageProcessor.processArguments(arguments)
        return checkIfErrorOccursOrHelpRequested(resultDictionary)
    }
    
    
    fileprivate func checkIfErrorOccursOrHelpRequested(_ dictionary: Options) -> Options {
        var dictionary = dictionary
        if dictionary.isEmpty {
            HelpFlag().execute()
            dictionary = ErrorDictionary
        }
        if let _ = dictionary[FlagKey] {
            dictionary = Options()
        }
        
        return dictionary
    }
    
    /**
    Returns an array with dictionaries with keys: "type" and "fileName" for reports saving.
    For xcode reporter type, value for "fileName" key will be empty.
    Must be called after processing arguments.
    */
    func getReporters() -> [OutputReporter] {
        return messageProcessor.getReporters()
    }
    
    /**
    Returns dictionary with rules and it's argument.
    Must be called after processing arguments.
    */
    func getRuleThresholds() -> CustomizationRule {
        return messageProcessor.getRuleThresholds()
    }
    
    /**
    Returns verbosity level indicated by user or default(error).
    Must be called after processing arguments.
    */
    func getVerbosityLevel() -> VerbosityLevel {
        return messageProcessor.getVerbosityLevel()
    }

}
