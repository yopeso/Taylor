//
//  OptionsProcessorTests.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/9/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class OptionsProcessorTests: QuickSpec {
    override func spec() {
        describe("OptionsProcessor") {
            do {
                
                let currentPath = FileManager.default.currentDirectoryPath
                
                var optionsProcessor : OptionsProcessor!
                
                func forceProcessOptions(_ options: [String]) -> Options {
                    return try! optionsProcessor.processOptions(arguments: options)
                }
                
                beforeEach {
                    optionsProcessor = OptionsProcessor()
                }
                
                afterEach {
                    optionsProcessor = nil
                }
                
                context("when arguments contain reporter option") {
                    
                    it("should create ReporterOption and append it to reporterOptions array") {
                        let reporterArgument = "plain:/path/to/plain-output.txt"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument]
                        _ = forceProcessOptions(inputArguments)
                        let reporterArg = optionsProcessor.factory.filterClassesOfType(ReporterOption().name)[0].optionArgument
                        let equal = (reporterArg == reporterArgument)
                        expect(equal).to(beTrue())
                    }
                    
                    it("should return empty dictionary if reporter argument does not contain : symbol and is not xcode reporter") {
                        let reporterArgument = "plain/path/to/plain-output.txt"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                    it("should return empty dictionary if reporter argument contain more than one : symbol") {
                        let reporterArgument = "plain:/path/to/:plain-output.txt"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                    it("should return empty dictionary if reporters type doesn't match possible types") {
                        let reporterArgument = "errorType:/path/to/plain-output.txt"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                    it("should not return empty dictionary(as when error occurs) when xcode is passed as argument for rule customization option") {
                        let reporterArgument = "xcode"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).toNot(beEmpty())
                    }
                    
                }
                
                context("when arguments contain multiple reporterOptions") {
                    
                    it("should append multiple reporterOptions to reporterOptions array") {
                        let reporterArgument1 = "plain:/path/to/plain-output.txt"
                        let reporterArgument2 = "json:/path/to/plain-output.json"
                        let reporterArgument3 = "xcode"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument1, ReporterShort, reporterArgument2, ReporterShort, reporterArgument3]
                        _ = forceProcessOptions(inputArguments)
                        var reportersArguments = [String]()
                        for arg in optionsProcessor.factory.filterClassesOfType(ReporterOption().name) {
                            reportersArguments.append(arg.optionArgument)
                        }
                        let equal = (reportersArguments == [reporterArgument1, reporterArgument2, reporterArgument3])
                        expect(equal).to(beTrue())
                    }
                    
                    it("should return empty dictionary if reportedOption type is repeated") {
                        let reporterArgument = "plain:/path/to/plain-output.txt"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument, ReporterShort, reporterArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                    it("should return empty dictionary if one of reportedOptions is not valid") {
                        let reporterArgument1 = "plain:/path/to/plain-output.txt"
                        let reporterArgument2 = "plain/path/to/plain-output.txt"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument1, ReporterShort, reporterArgument2]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                }
                
                context("when valid reporterOptions indicated") {
                    
                    it("should set reporters property with dictionaries(type and fileName key)") {
                        let reporterArgument = "plain:/path/to/plain-output.txt"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument]
                        _ = forceProcessOptions(inputArguments)
                        expect(optionsProcessor.factory.getReporters() == [["type" : "plain", "fileName" : "/path/to/plain-output.txt"]]).to(beTrue())
                    }
                    
                    it("should ser reporters property with type: xcode and fileName : EmptyString for xcode type reporter") {
                        let reporterArgument = "xcode"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument]
                        _ = forceProcessOptions(inputArguments)
                        expect(optionsProcessor.factory.getReporters() == [["type" : "xcode", "fileName" : ""]]).to(beTrue())
                    }
                    
                    it("should set multiple reporters into array of dictionaries(type and fileName key)") {
                        let reporterArgument = "plain:/path/to/plain-output.txt"
                        let reporterArgument1 = "xcode"
                        let inputArguments = [currentPath, ReporterLong, reporterArgument, ReporterLong, reporterArgument1]
                        _ = forceProcessOptions(inputArguments)
                        expect(optionsProcessor.factory.getReporters() == [["type" : "plain", "fileName" : "/path/to/plain-output.txt"], ["type" : "xcode", "fileName" : ""]]).to(beTrue())
                    }
                    
                }
                
                context("when arguments contain rule customization option") {
                    
                    it("should create ruleCustomizationOption and append it to ruleCustomizationOptions array") {
                        let rcArgument = "ExcessiveMethodLength=10"
                        let inputArguments = [currentPath, RuleCustomizationLong, rcArgument]
                        _ = forceProcessOptions(inputArguments)
                        let rcArguments = optionsProcessor.factory.filterClassesOfType(RuleCustomizationOption().name)[0].optionArgument
                        let equal = (rcArgument == rcArguments)
                        expect(equal).to(beTrue())
                    }
                    
                    it("should return empty dictionary if ruleCustommization argument does not contain = symbol") {
                        let rcArgument = "ExcessiveMethodLength10"
                        let inputArguments = [currentPath, RuleCustomizationShort, rcArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                    it("should return empty dictionary if ruleCustommization argument contain more than one = symbol") {
                        let rcArgument = "ExcessiveMethodLength=10=20"
                        let inputArguments = [currentPath, RuleCustomizationShort, rcArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                    it("should return empty dictionary if ruleCustommizations type doesn't match possible types") {
                        let rcArgument = "SomeErrorCaseCustomization=10"
                        let inputArguments = [currentPath, RuleCustomizationShort, rcArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                    it("should return empty dictionary if argument for rule is not an integer") {
                        let rcArgument = "SomeErrorCaseCustomization=1a0c"
                        let inputArguments = [currentPath, RuleCustomizationShort, rcArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                }
                
                context("when arguments contain multiple customization rules") {
                    
                    it("should append multiple customization rules to ruleCustomizationOptions array") {
                        let rcArgument1 = "ExcessiveMethodLength=10"
                        let rcArgument2 = "ExcessiveClassLength=400"
                        let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1, RuleCustomizationShort, rcArgument2]
                        _ = forceProcessOptions(inputArguments)
                        var rcArguments = [String]()
                        for arg in optionsProcessor.factory.filterClassesOfType(RuleCustomizationOption().name) {
                            rcArguments.append(arg.optionArgument)
                        }
                        let equal = ([rcArgument1, rcArgument2] == rcArguments)
                        expect(equal).to(beTrue())
                    }
                    
                    it("should return empty dictionary if rule customization types are repeated") {
                        let rcArgument = "ExcessiveMethodLength=10"
                        let inputArguments = [currentPath, RuleCustomizationLong, rcArgument, RuleCustomizationShort, rcArgument]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                    it("should return empty dictionary if one of rulesCustomizations is not valid") {
                        let rcArgument1 = "ExcessiveMethodLength=10"
                        let rcArgument2 = "ExcessiveClassLength400"
                        let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1, RuleCustomizationShort, rcArgument2]
                        let resultDictionary = forceProcessOptions(inputArguments)
                        expect(resultDictionary).to(beEmpty())
                    }
                    
                }
                
                context("when valid customizationRule is indicated") {
                    
                    it("should set customizationRules propery with dictionary(rule : complexity)") {
                        let rcArgument1 = "ExcessiveMethodLength=10"
                        let rcArgument2 = "ExcessiveClassLength=400"
                        let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1, RuleCustomizationShort, rcArgument2]
                        _ = forceProcessOptions(inputArguments)
                        expect(optionsProcessor.factory.customizationRules).to(equal(["ExcessiveMethodLength" : 10, "ExcessiveClassLength" : 400]))
                    }
                    
                    it("should set new customizationRules propery TooManyParameters") {
                        let rcArgument1 = "ExcessiveParameterList=10"
                        let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1]
                        _ = forceProcessOptions(inputArguments)
                        expect(optionsProcessor.factory.customizationRules).to(equal(["ExcessiveParameterList" : 10]))
                    }
                    
                    it("should return empty dictionary if multiple rules of type TooManyParameters are indicated") {
                        let rcArgument1 = "TooManyParameters=10"
                        let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1, RuleCustomizationShort, rcArgument1]
                        expect(forceProcessOptions(inputArguments)).to(beEmpty())
                    }
                    
                }
                
                it("should set default verbosity level to error when initialized") {
                    let inputArguments = [currentPath]
                    _ = forceProcessOptions(inputArguments)
                    expect(optionsProcessor.factory.verbosityLevel).to(equal(VerbosityLevel.error))
                }
                
                context("when verbosity level is inidicated") {
                    
                    it("should set optionsProcessor verbosityLevel property to indicated one") {
                        let verbosityArgument = "info"
                        let inputArguments = [currentPath, VerbosityLong, verbosityArgument]
                        _ = forceProcessOptions(inputArguments)
                        expect(optionsProcessor.factory.verbosityLevel).to(equal(VerbosityLevel.info))
                    }
                    
                    it("should return empty dictionary if verbosity argument doesn't math possible arguments") {
                        let verbosityArgument = "errorArgument"
                        let inputArguments = [currentPath, VerbosityLong, verbosityArgument]
                        expect(forceProcessOptions(inputArguments)).to(beEmpty())
                    }
                    
                    it("should return empty dictionary if multiple verbosity options are indicated") {
                        let verbosityArgument = "info"
                        let inputArguments = [currentPath, VerbosityLong, verbosityArgument, VerbosityShort, verbosityArgument]
                        expect(forceProcessOptions(inputArguments)).to(beEmpty())
                    }
                    
                }
                
                context("when setDefaultValuesToResultDictionary is called") {
                    
                    it("should set default values only for keys that was not indicated") {
                        var dictionary = [ResultDictionaryTypeKey : ["someType"]]
                        optionsProcessor.setDefaultValuesToResultDictionary(&dictionary)
                        expect(dictionary == [ResultDictionaryPathKey : [currentPath], ResultDictionaryTypeKey : ["someType"]]).to(beTrue())
                    }
                    
                    it("should set default values for dictionary") {
                        var dictionary = Options()
                        optionsProcessor.setDefaultValuesToResultDictionary(&dictionary)
                        expect(dictionary == [ResultDictionaryPathKey : [currentPath], ResultDictionaryTypeKey : [DefaultExtensionType]]).to(beTrue())
                    }
                    
                    it("should not change values if they are already setted") {
                        var dictionary = [ResultDictionaryPathKey : ["SomePath"], ResultDictionaryTypeKey : ["SomeExtension"]]
                        optionsProcessor.setDefaultValuesToResultDictionary(&dictionary)
                        expect(dictionary == [ResultDictionaryPathKey : ["SomePath"], ResultDictionaryTypeKey : ["SomeExtension"]]).to(beTrue())
                    }
                    
                    it("should set exclude paths from default excludesFile") {
                        let pathToExcludesFile = MockFileManager().testFile("excludes", fileType: "yml")
                        let pathToExcludesFileRootFolder = pathToExcludesFile.replacingOccurrences(of: "/excludes.yml", with: "")
                        var dictionary = [ResultDictionaryPathKey : [pathToExcludesFileRootFolder]]
                        optionsProcessor.setDefaultValuesToResultDictionary(&dictionary)
                        let resultsArrayOfExcludes = ["file.txt".formattedExcludePath(pathToExcludesFileRootFolder), "path/to/file.txt".formattedExcludePath(pathToExcludesFileRootFolder), "folder".formattedExcludePath(pathToExcludesFileRootFolder), "path/to/folder".formattedExcludePath(pathToExcludesFileRootFolder)]
                        expect(dictionary == [ResultDictionaryPathKey : [pathToExcludesFileRootFolder], ResultDictionaryTypeKey : [DefaultExtensionType], ResultDictionaryExcludesKey : resultsArrayOfExcludes]).to(beTrue())
                    }
                    
                }
            }
        }
    }
}

func ==<U: Hashable, T: Sequence>(lhs: [U: T], rhs: [U: T]) -> Bool where T.Iterator.Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    for (key, lValue) in lhs {
        guard let rValue = rhs[key], Array(lValue) == Array(rValue) else {
            return false
        }
    }
    return true
}

func ==<T: Hashable, U: Equatable>(lhs: [[T: U]], rhs: [[T: U]]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (index, dictionary) in lhs.enumerated() {
        if dictionary != rhs[index] { return false }
    }
    return true
}


