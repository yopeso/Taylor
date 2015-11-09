//
//  MockOptionsProcessor.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/7/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

@testable import TaylorFramework

class MockOptionsProcessor: OptionsProcessor {
    
    override func setDefaultValuesToResultDictionary(inout dictionary: Options) {
        setDefaultPathAndTypeToDictionary(&dictionary)
        if !isExcludesFileIndicated { setDefaultExcludesToDictionary(&dictionary) }
    }
    
    
    private func setDefaultPathAndTypeToDictionary(inout dictionary: Options) {
        let defaultDictionary = MockMessageProcessor().defaultDictionaryWithPathAndType()
        dictionary.setIfNotExist(defaultDictionary[ResultDictionaryPathKey] ?? [], forKey: ResultDictionaryPathKey)
        dictionary.setIfNotExist(defaultDictionary[ResultDictionaryTypeKey] ?? [], forKey: ResultDictionaryTypeKey)
    }
    
    
    private func setDefaultExcludesToDictionary(inout dictionary: Options) {
        var excludePaths = [String]()
        do {
            let excludesFilePath = MessageProcessor().defaultExcludesFilePathForDictionary(dictionary)
            excludePaths = try ExcludesFileReader().absolutePathsFromExcludesFile(excludesFilePath,  forAnalyzePath:dictionary[ResultDictionaryPathKey]![0])
        } catch {
            return
        }
        addExcludePathsToDictionary(&dictionary, excludePaths: excludePaths)
    }
    
    
    private func addExcludePathsToDictionary(inout dictionary: Options, excludePaths:[String]) {
        if excludePaths.isEmpty { return }
        dictionary.add(excludePaths, toKey: ResultDictionaryExcludesKey)
    }
    
}
