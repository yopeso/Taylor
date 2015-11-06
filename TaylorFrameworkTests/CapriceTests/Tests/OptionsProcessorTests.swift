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
            
            let currentPath = NSFileManager.defaultManager().currentDirectoryPath
            
            var optionsProcessor : OptionsProcessor!
                        
            beforeEach {
                optionsProcessor = OptionsProcessor()
            }
            
            afterEach {
                optionsProcessor = nil
            }
            
            context("when arguments contain reporter option") {
                
//                it("should create ReporterOption and append it to reporterOptions array") {
//                    let reporterArgument = "plain:/path/to/plain-output.txt"
//                    let inputArguments = [currentPath, ReporterLong, reporterArgument]
//                    optionsProcessor.processOptions(inputArguments)
//                    let reporterArg = optionsProcessor.factory.reporterOptions[0].optionArgument
//                    let equal = (reporterArg == reporterArgument)
//                    expect(equal).to(beTrue())
//                }
                
                it("should return empty dictionary if reporter argument does not contain : symbol and is not xcode reporter") {
                    let reporterArgument = "plain/path/to/plain-output.txt"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
                it("should return empty dictionary if reporter argument contain more than one : symbol") {
                    let reporterArgument = "plain:/path/to/:plain-output.txt"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
                it("should return empty dictionary if reporters type doesn't match possible types") {
                    let reporterArgument = "errorType:/path/to/plain-output.txt"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
                it("should not return empty dictionary(as when error occurs) when xcode is passed as argument for rule customization option") {
                    let reporterArgument = "xcode"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).toNot(beEmpty())
                }
                
            }
            
            context("when arguments contain multiple reporterOptions") {
                
//                it("should append multiple reporterOptions to reporterOptions array") {
//                    let reporterArgument1 = "plain:/path/to/plain-output.txt"
//                    let reporterArgument2 = "json:/path/to/plain-output.json"
//                    let reporterArgument3 = "xcode"
//                    let inputArguments = [currentPath, ReporterLong, reporterArgument1, ReporterShort, reporterArgument2, ReporterShort, reporterArgument3]
//                    optionsProcessor.processOptions(inputArguments)
//                    var reportersArguments = [String]()
//                    for arg in optionsProcessor.factory.reporterOptions {
//                        reportersArguments.append(arg.optionArgument)
//                    }
//                    let equal = (reportersArguments == [reporterArgument1, reporterArgument2, reporterArgument3])
//                    expect(equal).to(beTrue())
//                }
                
                it("should return empty dictionary if reportedOption type is repeated") {
                    let reporterArgument = "plain:/path/to/plain-output.txt"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument, ReporterShort, reporterArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
                it("should return empty dictionary if one of reportedOptions is not valid") {
                    let reporterArgument1 = "plain:/path/to/plain-output.txt"
                    let reporterArgument2 = "plain/path/to/plain-output.txt"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument1, ReporterShort, reporterArgument2]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
            }
            
            context("when valid reporterOptions indicated") {
                
                it("should set reporters property with dictionaries(type and fileName key)") {
                    let reporterArgument = "plain:/path/to/plain-output.txt"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument]
                    optionsProcessor.processOptions(inputArguments)
                    expect(optionsProcessor.factory.getReporters()).to(equal([["type" : "plain", "fileName" : "/path/to/plain-output.txt"]]))
                }
                
                it("should ser reporters property with type: xcode and fileName : EmptyString for xcode type reporter") {
                    let reporterArgument = "xcode"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument]
                    optionsProcessor.processOptions(inputArguments)
                    expect(optionsProcessor.factory.getReporters()).to(equal([["type" : "xcode", "fileName" : ""]]))
                }
                
                it("should set multiple reporters into array of dictionaries(type and fileName key)") {
                    let reporterArgument = "plain:/path/to/plain-output.txt"
                    let reporterArgument1 = "xcode"
                    let inputArguments = [currentPath, ReporterLong, reporterArgument, ReporterLong, reporterArgument1]
                    optionsProcessor.processOptions(inputArguments)
                    expect(optionsProcessor.factory.getReporters()).to(equal([["type" : "plain", "fileName" : "/path/to/plain-output.txt"], ["type" : "xcode", "fileName" : ""]]))
                }
                
            }
            
            context("when arguments contain rule customization option") {
                
//                it("should create ruleCustommizationOption and append it to ruleCustomizationOptions array") {
//                    let rcArgument = "ExcessiveMethodLength=10"
//                    let inputArguments = [currentPath, RuleCustomizationLong, rcArgument]
//                    optionsProcessor.processOptions(inputArguments)
//                    let rcArguments = optionsProcessor.infoOptionsProcessor.ruleCustomizationOptions[0].optionArgument
//                    let equal = (rcArgument == rcArguments)
//                    expect(equal).to(beTrue())
//                }
                
                it("should return empty dictionary if ruleCustommization argument does not contain = symbol") {
                    let rcArgument = "ExcessiveMethodLength10"
                    let inputArguments = [currentPath, RuleCustomizationShort, rcArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
                it("should return empty dictionary if ruleCustommization argument contain more than one = symbol") {
                    let rcArgument = "ExcessiveMethodLength=10=20"
                    let inputArguments = [currentPath, RuleCustomizationShort, rcArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
                it("should return empty dictionary if ruleCustommizations type doesn't match possible types") {
                    let rcArgument = "SomeErrorCaseCustomization=10"
                    let inputArguments = [currentPath, RuleCustomizationShort, rcArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
                it("should return empty dictionary if argument for rule is not an integer") {
                    let rcArgument = "SomeErrorCaseCustomization=1a0c"
                    let inputArguments = [currentPath, RuleCustomizationShort, rcArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
            }
            
            context("when arguments contain multiple customization rules") {
                
//                it("should append multiple customization rules to ruleCustomizationOptions array") {
//                    let rcArgument1 = "ExcessiveMethodLength=10"
//                    let rcArgument2 = "ExcessiveClassLength=400"
//                    let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1, RuleCustomizationShort, rcArgument2]
//                    optionsProcessor.processOptions(inputArguments)
//                    var rcArguments = [String]()
//                    for arg in optionsProcessor.factory.ruleCustomizationOptions {
//                        rcArguments.append(arg.optionArgument)
//                    }
//                    let equal = ([rcArgument1, rcArgument2] == rcArguments)
//                    expect(equal).to(beTrue())
//                }
                
                it("should return empty dictionary if rule customization types are repeated") {
                    let rcArgument = "ExcessiveMethodLength=10"
                    let inputArguments = [currentPath, RuleCustomizationLong, rcArgument, RuleCustomizationShort, rcArgument]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
                it("should return empty dictionary if one of rulesCustomizations is not valid") {
                    let rcArgument1 = "ExcessiveMethodLength=10"
                    let rcArgument2 = "ExcessiveClassLength400"
                    let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1, RuleCustomizationShort, rcArgument2]
                    let resultDictionary = optionsProcessor.processOptions(inputArguments)
                    expect(resultDictionary).to(beEmpty())
                }
                
            }
            
            context("when valid customizationRule is indicated") {
                
                it("should set customizationRules propery with dictionary(rule : complexity)") {
                    let rcArgument1 = "ExcessiveMethodLength=10"
                    let rcArgument2 = "ExcessiveClassLength=400"
                    let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1, RuleCustomizationShort, rcArgument2]
                    optionsProcessor.processOptions(inputArguments)
                    expect(optionsProcessor.factory.customizationRules).to(equal(["ExcessiveMethodLength" : 10, "ExcessiveClassLength" : 400]))
                }
                
                it("should set new customizationRules propery TooManyParameters") {
                    let rcArgument1 = "ExcessiveParameterList=10"
                    let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1]
                    optionsProcessor.processOptions(inputArguments)
                    expect(optionsProcessor.factory.customizationRules).to(equal(["ExcessiveParameterList" : 10]))
                }
                
                it("should return empty dictionary if multiple rules of type TooManyParameters are indicated") {
                    let rcArgument1 = "TooManyParameters=10"
                    let inputArguments = [currentPath, RuleCustomizationLong, rcArgument1, RuleCustomizationShort, rcArgument1]
                    expect(optionsProcessor.processOptions(inputArguments)).to(beEmpty())
                }
                
            }
            
            it("should set default verbosity level to error when initialized") {
                let inputArguments = [currentPath]
                optionsProcessor.processOptions(inputArguments)
                expect(optionsProcessor.factory.verbosityLevel).to(equal(VerbosityLevel.Error))
            }
            
            context("when verbosity level is inidicated") {
                
                it("should set optionsProcessor verbosityLevel property to indicated one") {
                    let verbosityArgument = "info"
                    let inputArguments = [currentPath, VerbosityLong, verbosityArgument]
                    optionsProcessor.processOptions(inputArguments)
                    expect(optionsProcessor.factory.verbosityLevel).to(equal(VerbosityLevel.Info))
                }
                
                it("should return empty dictionary if verbosity argument doesn't math possible arguments") {
                    let verbosityArgument = "errorArgument"
                    let inputArguments = [currentPath, VerbosityLong, verbosityArgument]
                    expect(optionsProcessor.processOptions(inputArguments)).to(beEmpty())
                }
                
                it("should return empty dictionary if multiple verbosity options are indicated") {
                    let verbosityArgument = "info"
                    let inputArguments = [currentPath, VerbosityLong, verbosityArgument, VerbosityShort, verbosityArgument]
                    expect(optionsProcessor.processOptions(inputArguments)).to(beEmpty())
                }
                
            }
            
        }
    }
}
