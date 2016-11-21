//
//  MockOptionsProcessor.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/7/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

@testable import TaylorFramework
import ExcludesFileReader

class MockOptionsProcessor: OptionsProcessor {
    
    override func setDefaultValuesToResultDictionary(_ dictionary: inout Options) {
        setDefaultPathAndTypeToDictionary(&dictionary)
        if !isExcludesFileIndicated { setDefaultExcludesToDictionary(&dictionary) }
    }
    
    
    fileprivate func setDefaultPathAndTypeToDictionary(_ dictionary: inout Options) {
        let defaultDictionary = MockMessageProcessor().defaultDictionaryWithPathAndType()
        dictionary.setIfNotExist(defaultDictionary[ResultDictionaryPathKey] ?? [], forKey: ResultDictionaryPathKey)
        dictionary.setIfNotExist(defaultDictionary[ResultDictionaryTypeKey] ?? [], forKey: ResultDictionaryTypeKey)
    }
    
    
    fileprivate func setDefaultExcludesToDictionary(_ dictionary: inout Options) {
        var excludePaths = [String]()
        do {
            let excludesFilePath = MessageProcessor().defaultExcludesFilePathForDictionary(dictionary)
            excludePaths = try ExcludesFileReader().absolutePathsFromExcludesFile(excludesFilePath,  forAnalyzePath:dictionary[ResultDictionaryPathKey]![0])
        } catch {
            return
        }
        addExcludePathsToDictionary(&dictionary, excludePaths: excludePaths)
    }
    
    
    fileprivate func addExcludePathsToDictionary(_ dictionary: inout Options, excludePaths:[String]) {
        if excludePaths.isEmpty { return }
        dictionary.add(excludePaths, toKey: ResultDictionaryExcludesKey)
    }
    
}
