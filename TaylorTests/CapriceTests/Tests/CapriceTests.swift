//
//  CapriceTests.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/11/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Quick
import Nimble
import Printer
@testable import Caprice

class CapriceTests: QuickSpec {
    override func spec() {
        describe("Caprice") {
            let currentPath = NSFileManager.defaultManager().currentDirectoryPath
            var caprice : Caprice!
            
            beforeEach {
                caprice = Caprice()
            }
            
            afterEach {
                caprice = nil
            }
            
            context("when no arguments are passed") {
                
                it("should set default values for dictionary (no excludesFile)") {
                    let inputArguments = [currentPath]
                    expect(caprice.processArguments(inputArguments)).to(equal([ResultDictionaryPathKey : [currentPath], ResultDictionaryTypeKey : [DefaultExtensionType]]))
                }
                
                it("should return default verbosity") {
                    let inputArguments = [currentPath]
                    caprice.processArguments(inputArguments)
                    expect(caprice.getVerbosityLevel()).to(equal(VerbosityLevel.Error))
                }
                
                it("should return empty array of reporters") {
                    let inputArguments = [currentPath]
                    caprice.processArguments(inputArguments)
                    expect(caprice.getReporters()).to(beEmpty())
                }
                
                it("should return empty array of reporters") {
                    let inputArguments = [currentPath]
                    caprice.processArguments(inputArguments)
                    expect(caprice.getRuleThresholds()).to(beEmpty())
                }
                
            }
            
            context("when help is requested") {
                
                it("should return an empty dictionary") {
                    let inputArguments = [currentPath, HelpOptionKey]
                    caprice.processArguments(inputArguments)
                    expect(caprice.getRuleThresholds()).to(beEmpty())
                }
                
            }
            
            context("when valid reporters are indicated") {
                
                it("should return them using getReporters function") {
                    let inputArguments = [currentPath, ReporterLong, "plain:/path/to/plain.txt"]
                    caprice.processArguments(inputArguments)
                    expect(caprice.getReporters()).to(equal([["type" : "plain", "fileName" : "/path/to/plain.txt"]]))
                }
                
            }
            
            context("when valid customization rules are indicated") {
                
                it("should return them using getRuleThresholds function") {
                    let inputArguments = [currentPath, RuleCustomizationLong, "ExcessiveMethodLength=10"]
                    caprice.processArguments(inputArguments)
                    expect(caprice.getRuleThresholds()).to(equal(["ExcessiveMethodLength" : 10]))
                }
                
            }
            
            context("when valid verbosity level is indicated ") {
                
                it("should return it using getVerbosityLevel function") {
                    let inputArguments = [currentPath, VerbosityLong, VerbosityLevelInfo]
                    caprice.processArguments(inputArguments)
                    expect(caprice.getVerbosityLevel()).to(equal(VerbosityLevel.Info))
                }
                
            }
            
            context("when all options are indicated (no ecludesFile)") {
                
                it("should set all options") {
                    let localCaprice = Caprice()
                    let pathArg = "/somePath"
                    let excludeArg = "excludePath"
                    let fileArg = "fileArg"
                    let typeArg = "someType"
                    let inputArguments = [currentPath, PathLong, pathArg, ExcludeLong, excludeArg, FileLong, fileArg, TypeLong, typeArg, ReporterLong, "plain:/path/to/plain.txt", RuleCustomizationLong, "ExcessiveMethodLength=10", VerbosityLong, VerbosityLevelWarning]
                    let resultDictionary = localCaprice.processArguments(inputArguments)
                    expect(resultDictionary).to(equal([ResultDictionaryPathKey : [pathArg], ResultDictionaryExcludesKey : [pathArg + "/" + excludeArg], ResultDictionaryFileKey : [pathArg + "/" + fileArg], ResultDictionaryTypeKey : ["someType"]]))
                    expect(localCaprice.getVerbosityLevel()).to(equal(VerbosityLevel.Warning))
                    expect(localCaprice.getReporters()).to(equal([["type" : "plain", "fileName" : "/path/to/plain.txt"]]))
                    expect(localCaprice.getRuleThresholds()).to(equal(["ExcessiveMethodLength" : 10]))
                }
                
            }
            
            context("when one of the indicaed option is invalid") {
                
                it("should return dictionary with current path and no special options must be setted (only default verbosity level)") {
                    let localCaprice = Caprice()
                    let pathArg = "somePath"
                    let excludeArg = "excludePath"
                    let fileArg = "fileArg"
                    let typeArg = "someType"
                    let inputArguments = [currentPath, PathLong, pathArg, ExcludeLong, excludeArg, FileLong, fileArg, TypeLong, typeArg, ReporterLong, "invalidReporter", RuleCustomizationLong, "ExcessiveMethodLength=10", VerbosityLong, VerbosityLevelWarning]
                    let resultDictionary = localCaprice.processArguments(inputArguments)
                    expect(resultDictionary).to(equal([ResultDictionaryPathKey : [currentPath]]))
                    expect(localCaprice.getVerbosityLevel()).to(equal(VerbosityLevel.Error))
                    expect(localCaprice.getReporters()).to(beEmpty())
                    expect(localCaprice.getRuleThresholds()).to(beEmpty())
                }
                
            }
            
            it("should return current path if error pccures") {
                let inputArguments = [currentPath, ExcludesFileLong, "errorFile.txt"]
                expect(caprice.processArguments(inputArguments)).to(equal([ResultDictionaryPathKey : [currentPath]]))
            }
            
        }
    }
}
