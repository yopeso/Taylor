//
//  ExcludesFileReaderTests.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Quick
import Nimble
@testable import Caprice

let TestFileName = "excludes"
let TestFileExtension = "yml"

class ExcludesFileReaderTests: QuickSpec {

    override func spec() {
        describe("Excludes File Reader") {
            var fileManager : MockFileManager!
            var excludesFileReader : ExcludesFileReader!
            var testFilePath : String!
            var analyzePath : String!
            
            beforeEach {
                fileManager = MockFileManager()
                excludesFileReader = ExcludesFileReader(fileManager:fileManager)
                testFilePath = fileManager.testFile(TestFileName, fileType: TestFileExtension)
                analyzePath = testFilePath.stringByReplacingOccurrencesOfString(DefaultExcludesFile, withString: "")
            }
            
            afterEach {
                excludesFileReader = nil
                fileManager = nil
                
            }
            
            it("should throw exception if file does not exists at path") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(DefaultExcludesFile, forAnalyzePath: analyzePath)
                    }.to(throwError(CommandLineError.ExcludesFileError("")))
            }
            
            it("should throw exception if file exists but it is directory") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(DefaultExcludesFile, forAnalyzePath: analyzePath)
                    }.to(throwError())
            }
            
            it("should throw exception if file exists but is not of extension .yml") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(DefaultExcludesFile, forAnalyzePath: analyzePath)
                    }.to(throwError())
            }
            
            it("shouldn't throw exception for existing file with .yml extension") {
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(testFilePath, forAnalyzePath: analyzePath)
                    }.toNot(throwError())
            }
            
            it("shouldn't throw exception for test yml file") {
                testFilePath = fileManager.testFile(TestFileName, fileType: TestFileExtension)
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(testFilePath, forAnalyzePath: analyzePath)
                    }.toNot(throwError())
            }
            
            it("should return an empty array for empty file") {
                expect{
                    try excludesFileReader.absolutePathsFromExcludesFile(analyzePath + "/emptyExcludes.yml", forAnalyzePath: analyzePath)
                }.to(equal([]))
            }
            
            it("should return an array of absolute paths excluding files with ** prefix") {
                let analyzePath = testFilePath.stringByReplacingOccurrencesOfString("/excludes.yml", withString: "")
                let resultsArray = ["file.txt".formattedExcludePath(analyzePath), "path/to/file.txt".formattedExcludePath(analyzePath), "folder".formattedExcludePath(analyzePath), "path/to/folder".formattedExcludePath(analyzePath)]
                expect {
                    try excludesFileReader.absolutePathsFromExcludesFile(testFilePath, forAnalyzePath: analyzePath)
                }.to(equal(resultsArray))
            }
            
        }
    }

}
