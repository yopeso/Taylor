//
//  MockOptionsProcessor.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/7/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

@testable import TaylorFramework

class MockOptionsProcessor: OptionsProcessor {
    
    override func setDefaultValuesToResultDictionary(inout dictionary : [String : [String]]) {
        let defaultDictionary = MockMessageProcessor().defaultDictionaryWithPathAndType()
        if dictionary[ResultDictionaryPathKey] == nil {
            dictionary[ResultDictionaryPathKey] = defaultDictionary[ResultDictionaryPathKey]
        }
        if dictionary[ResultDictionaryTypeKey] == nil {
            dictionary[ResultDictionaryTypeKey] = defaultDictionary[ResultDictionaryTypeKey]
        }
        if !isExcludesFileIndicated {
            let excludesFileReader = ExcludesFileReader()
            var excludePaths = [String]()
            do {
                let pathToExcludesFile = MessageProcessor().defaultExcludesFilePathForDictionary(dictionary)
                excludePaths = try excludesFileReader.absolutePathsFromExcludesFile(DefaultExcludesFile, forAnalyzePath: pathToExcludesFile)
            } catch {
                return
            }
            if excludePaths.count > 0 {
                if dictionary[ResultDictionaryExcludesKey] == nil {
                    dictionary[ResultDictionaryExcludesKey] = excludePaths
                } else {
                    dictionary[ResultDictionaryExcludesKey]! += excludePaths
                }
            }
            
        }
    }
    
}
