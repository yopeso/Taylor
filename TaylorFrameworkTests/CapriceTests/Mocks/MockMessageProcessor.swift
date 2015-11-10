//
//  MockMessageProcessor.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/7/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation
@testable import TaylorFramework

class MockMessageProcessor : MessageProcessor {
    
    override func defaultResultDictionary() -> [String : [String]] {
        var defaultDictionary = defaultDictionaryWithPathAndType()
        setDefaultExcludesIfExistsToDictionary(&defaultDictionary)
        
        return defaultDictionary
    }
    
    
    override func setDefaultExcludesIfExistsToDictionary(inout dictionary: Options) {
        let fileManager = MockFileManager()
        let pathToDefaultExcludesFile = fileManager.testFile("excludes", fileType: "yml")
        
        let excludesFileReader = ExcludesFileReader()
        var excludePaths = [String]()
        do {
            let pathToExcludesFile = pathToDefaultExcludesFile.absolutePath()
            excludePaths = try excludesFileReader.absolutePathsFromExcludesFile(pathToExcludesFile, forAnalyzePath: dictionary[ResultDictionaryPathKey]![0])
        } catch {
            return
        }
        if !excludePaths.isEmpty {
            dictionary[ResultDictionaryExcludesKey] = excludePaths
        }
    }
    
    
    override func processMultipleArguments(arguments:[String]) -> Options {
        
        if arguments.count.isOdd {
            let optionsProcessor = MockOptionsProcessor()
            return optionsProcessor.processOptions(arguments)
        } else if (arguments.count == 2) && (arguments.second == HelpOptionKey) {
            do {
                try printHelp()
            } catch {
                print("\nCan't find help file")
                return [String : [String]]()
            }
            return ["help" : ["help requested"]]
        } else {
            print("\nInvalid options was indicated")
            return [String : [String]]()
        }
    }
    
    
    override func printHelp() throws {
        let bundle = NSBundle(forClass: self.dynamicType)
        if let helpMessage = bundle.pathForResource("ErrorHelp", ofType: "txt") {
            print(helpMessage)
        } else {
            throw CommandLineError.CannotReadFromHelpFile
        }
    }
    
}
