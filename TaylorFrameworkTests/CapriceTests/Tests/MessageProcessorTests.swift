//
//  MessagePreccessingTests.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 8/26/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class MessageProcessorTests: QuickSpec {
    override func spec() {
        describe("MessageProcesor") {
            var messageProcessor : MessageProcessor!
            let currentPath = NSFileManager.defaultManager().currentDirectoryPath
            
            beforeEach {
                messageProcessor = MessageProcessor()
            }
            
            afterEach {
                messageProcessor = nil
            }
            
            it("should return current path and type for empty arguments, excludes file does not exists so excludes are not setted") {
                let inputArguments = [currentPath]
                expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [currentPath], "type" : ["swift"]]))
            }
            
            it("should return empty dictionary for invalid number of arguments") {
                let inputArguments = [currentPath, "someArgument"]
                expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
            }
            
            it("should replace default path if path is indicated") {
                let pathArgument = "somePath"
                var inputArguments = [currentPath, PathLong, pathArgument]
                let absolutePath = currentPath + "/" + pathArgument
                expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [absolutePath], "type" : ["swift"]]))
                inputArguments = [currentPath, PathShort, pathArgument]
                expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [absolutePath], "type" : ["swift"]]))
            }
            
            it("should set path and type if they are indicated") {
                let pathArgument = "somePath"
                let typeArgument = "someType"
                let inputArguments = [currentPath, PathLong, pathArgument, TypeLong, typeArgument]
                let absolutePath = currentPath + "/" + pathArgument
                expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [absolutePath], "type" : [typeArgument]]))
            }
            
            it("should persist default path if only type is indicated") {
                let typeArgument = "someType"
                var inputArguments = [currentPath, TypeLong, typeArgument]
                expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [currentPath], "type" : [typeArgument]]))
                inputArguments = [currentPath, TypeShort, typeArgument]
                expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [currentPath], "type" : [typeArgument]]))
            }
            
            it("should add files") {
                let fileArgument = "someFile"
                let inputArguments = [currentPath, FileLong, fileArgument, FileShort, fileArgument]
                let absolutePathToFile = currentPath + "/" + fileArgument
                expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [currentPath], "files" : [absolutePathToFile, absolutePathToFile], "type" : ["swift"]]))
            }
            
            it("should add exclude paths") {
                let excludeArgument = "someExcludePath"
                let inputArguments = [currentPath, ExcludeLong, excludeArgument, ExcludeShort, excludeArgument]
                let absolutePathToExclude = currentPath + "/" + excludeArgument
                expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [currentPath], "type" : ["swift"], "excludes" : [absolutePathToExclude, absolutePathToExclude]]))
            }
            
            it("should return empty dictionary if option does not contain prefix") {
                let invalidOption = "path"
                let somePath = "somePath"
                let inputArguments = [currentPath, invalidOption, somePath]
                expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
            }
            
            it("should return empty dictionary if arguments contain an invalid option with prefix") {
                let invalidOption = "-path"
                let somePath = "somePath"
                let inputArguments = [currentPath, invalidOption, somePath]
                expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
            }
            
            it("should return empty dictionary if multiple paths are indicated") {
                let somePath = "somePath"
                let inputArguments = [currentPath, PathLong, somePath, PathLong, somePath]
                expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
            }
            
            it("should return empty dictionary if multiple types are indicated") {
                let someType = "someType"
                let inputArguments = [currentPath, TypeLong, someType, TypeLong, someType]
                expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
            }
            
            
            context("File search (.*)") {
                
                it("should return same exclude argument if it have .* prefix and sufix") {
                    let excludeArgument = ".*someExcludeFile.*"
                    let inputArguments = [currentPath, ExcludeLong, excludeArgument, ExcludeShort, excludeArgument]
                    expect(messageProcessor.processArguments(inputArguments)).to(equal(["path" : [currentPath], "type" : ["swift"], "excludes" : [excludeArgument, excludeArgument]]))
                }
                
                it("should return empty dictioanry if excludes path contains .* prefix or sufix") {
                    let excludePath = ".*somePath"
                    let excludePath1 = "somePath.*"
                    let inputArguments = [currentPath, ExcludeShort, excludePath, ExcludeLong, excludePath1]
                    expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
                }
                
            }
            
            context("Excludes File") {
                
                it("should return empty dictionary if multiple excludesFiles was indicated") {
                    let somePath = "somePath"
                    let inputArguments = [currentPath, ExcludesFileLong, somePath, ExcludesFileShort, somePath]
                    expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
                }
                
                it("default excludes file must be read and set to result dictionary if it exists, in plus at default path and type") {
                    let mockMessageProcessor = MockMessageProcessor()
                    let inputArguments = [currentPath]
                    let resultsArrayOfExcludes = ["file.txt".formattedExcludePath(currentPath), "path/to/file.txt".formattedExcludePath(currentPath), "folder".formattedExcludePath(currentPath), "path/to/folder".formattedExcludePath(currentPath)]
                    expect(mockMessageProcessor.processArguments(inputArguments)).to(equal(["path" : [currentPath], "type" : ["swift"], "excludes" : resultsArrayOfExcludes]))
                }
                
                it("should set exclude path and paths from excludeFile together") {
                    let mockMessageProcessor = MockMessageProcessor()
                    let somePath = "/somePath"
                    let pathToExcludesFile = MockFileManager().testFile("excludes", fileType: "yml")
                    let resultsArrayOfExcludes = [somePath, "file.txt".formattedExcludePath(currentPath), "path/to/file.txt".formattedExcludePath(currentPath), "folder".formattedExcludePath(currentPath), "path/to/folder".formattedExcludePath(currentPath)]
                    let inputArguments = [currentPath, ExcludeLong, somePath, ExcludesFileLong, pathToExcludesFile]
                    let dictionary = mockMessageProcessor.processArguments(inputArguments)
                    expect(dictionary).to(equal(["path" : [currentPath], "type" : ["swift"], "excludes" : resultsArrayOfExcludes]))
                }
                
                it("should set only exclude path if excludesFile does not exists at current path (we don't change path of default excludesFile path to one from bundle)") {
                    let mockMessageProcessor = MockMessageProcessor()
                    let somePath = "somePath"
                    let inputArguments = [currentPath, PathShort, currentPath, ExcludeLong, somePath]
                    let dictionary = mockMessageProcessor.processArguments(inputArguments)
                    expect(dictionary).to(equal(["path" : [currentPath], "type" : ["swift"], "excludes" : [currentPath + "/" + somePath]]))
                }
                
            }
            
            context("when single option is indicated") {
                
                it("should return error dictionary if help file was not found") {
                    let mockMessageProcessor = MockMessageProcessor()
                    let inputArguments = [currentPath, FlagKey]
                    expect(mockMessageProcessor.processArguments(inputArguments)).to(beEmpty())
                }
                it("should return empty dictionary if single option is not help") {
                    let inputArguments = [currentPath, "errorOption"]
                    expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
                }
                
            }
            
            context("when getReporters is called") {
                
                it("should return an empty array if no reporters was passed as parameters") {
                    messageProcessor.processArguments([currentPath])
                    expect(messageProcessor.getReporters()).to(beEmpty())
                }
                
                it("should return array with specific dictionaries if reporter was passed") {
                    messageProcessor.processArguments([currentPath, ReporterLong, "plain:/path/to/plain-output.txt"])
                    expect(messageProcessor.getReporters()).to(equal([["type" : "plain", "fileName" : "/path/to/plain-output.txt"]]))
                }
            }
            
            it("should return empty dictionary if invalid reporterOption was indicated") {
                let resultDictionary = messageProcessor.processArguments([currentPath, ReporterLong, "plain/path/to/plain-output.txt"])
                expect(resultDictionary).to(beEmpty())
            }
            
            context("when getRuleThresholds is called") {
                
                it("shoul return an empty dictionary if no rules was indicated") {
                    messageProcessor.processArguments([currentPath])
                    expect(messageProcessor.getRuleThresholds()).to(beEmpty())
                }
                
                it("should return dictionary with rules if they were indicated") {
                    messageProcessor.processArguments([currentPath, RuleCustomizationShort, "ExcessiveMethodLength=10"])
                    expect(messageProcessor.getRuleThresholds()).to(equal(["ExcessiveMethodLength" : 10]))
                }
                
            }
            
            it("should return empty dictionary if invalid ruleCustomization was indicated") {
                let inputArguments = [currentPath, RuleCustomizationShort, "ExcessiveMethodLength10"]
                expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
            }
            
            context("when getVerbosityLevel is called") {
                
                it("should return default(error) verbosity if no verbosity was indicated") {
                    messageProcessor.processArguments([currentPath])
                    expect(messageProcessor.getVerbosityLevel()).to(equal(VerbosityLevel.Error))
                }
                
                it("should return rigth verbosity if that was indicated") {
                    messageProcessor.processArguments([currentPath, VerbosityLong, "info"])
                    expect(messageProcessor.getVerbosityLevel()).to(equal(VerbosityLevel.Info))
                }
                
            }
            
            it("should return empty dictionary if invalid verbosity was indicated") {
                let inputArguments = [currentPath, VerbosityShort, "errorArgument"]
                expect(messageProcessor.processArguments(inputArguments)).to(beEmpty())
            }
            
            it("should append default excludes file to path from passed dictionary and not current path") {
                let inputArguments = [currentPath, PathLong, "/somePath"]
                let resultDiciotnary = messageProcessor.processArguments(inputArguments)
                expect(messageProcessor.defaultExcludesFilePathForDictionary(resultDiciotnary)).to(equal("/somePath/excludes.yml"))
                expect(messageProcessor.defaultExcludesFilePathForDictionary(resultDiciotnary)).toNot(equal(currentPath + "/excludes.yml"))
            }
            
        }
    }
}
