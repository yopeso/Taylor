//
//  FileContentTests.swift
//  Scissors
//
//  Created by Alexandru Culeva on 9/3/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SourceKittenFramework
@testable import TaylorFramework

class MockFileReader {
    func pathForFile(_ fileName: String, fileType: String) -> String {
        let testBundle = Bundle(for: type(of: self))
        return testBundle.path(forResource: fileName, ofType: fileType)!
    }
}

class TokenizerTests: QuickSpec {
    override func spec() {
        let reader = MockFileReader()
        
        let scissors = Scissors()
        describe("tokenizer") {
            it("should return empty tree if given file does not exist") {
                expect(scissors.tokenizeFileAtPath("unexisting.path")).to(equal(
                    FileContent(path: "", components: [])))
            }
            it("should build the tree from a given array of components") {
                let components = arrayComponents()
                let expectedTree = componentsForArrayComponents()
                let root = ExtendedComponent(type: .class, range: OffsetRange(start: 0, end: 11))
                let returnTree = Tree(file: File(contents: "")).arrayToTree(components, root: root)
                expect(returnTree).to(equal(expectedTree))
            }
            it("should return empty array when empty string") {
                let path = reader.pathForFile("TestFileEmpty", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: [])
                expect(returnContent).to(equal(expectedContent))
            }
            it("should return array with one component when one class") {
                let path = reader.pathForFile("TestFileOneClass", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path,
                    components: componentsOneClass())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should return array with a class and a func") {
                let path = reader.pathForFile("TestFileOneClassOneFunc", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path,
                    components: componentsClassAndFunc())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should check for emptylines") {
                let path = reader.pathForFile("TestFileEmptyLines", fileType: "txt")
                let content = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path,
                    components: componentsEmptyLines())
                expect(content).to(equal(expectedContent))
            }
            it("should check for comments") {
                let path = reader.pathForFile("TestFileComments", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path,
                    components: componentsComments())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should not check if inside string") {
                let path = reader.pathForFile("TestFileStrings", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path,
                    components: componentsForStrings())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should check structs and enums") {
                let path = reader.pathForFile("TestFileOneStructOneEnum", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path,
                    components: componentsOneStructOneEnum())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should check ifs and elses") {
                let path = reader.pathForFile("TestFileIfElse", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsIfElse())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should recognize elseif as a separate component") {
                let path = reader.pathForFile("TestFileElseif", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsElseIf())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should create a multi-level tree properly") {
                let path = reader.pathForFile("TestFileRandom", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForRandom())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should see AND and OR components as part of repeat, if they are inside while") {
                let path = reader.pathForFile("TestFileRepeatWhile", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForRepeatWhile())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should find parents of ternary and nil-coalescing") {
                let path = reader.pathForFile("TestFileTernaryNilc", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForTernaryNilc())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should return components in the correct order") {
                let path = reader.pathForFile("TestFileIfElifElse", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForIfElifElse())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should see do-catch block as inside IF if so") {
                let path = reader.pathForFile("TestFileDoCatchInsideIf", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForDoCatchInsideIf())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should recognize computed properties as functions along with their components") {
                let path = reader.pathForFile("TestFileComputedProperties", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForComputedProperty())
                expect(returnContent).to(equal(expectedContent))
            }
            
            it("should recognize closures as functions") {
                let path = reader.pathForFile("TestFileClosures", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForClosures())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should recognize the inners of getters and setters as parts of variables") {
                let path = reader.pathForFile("TestFileGettersSetters", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForGettersSetters())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should recognize brace with parameter as closure") {
                let path = reader.pathForFile("TestFileBraceWithParameter", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForBraceWithParameters())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should run for files with 500 lines") {
                let path = reader.pathForFile("TestFileMoreThan500", fileType: "swift")
                _ = scissors.tokenizeFileAtPath(path)
            }
            it("should run for files more than 1K lines") {
                let path = reader.pathForFile("TestFileMoreThan1K", fileType: "swift")
                _ = scissors.tokenizeFileAtPath(path)
            }
            it("should run for files more than 2K lines") {
                let path = reader.pathForFile("TestFileMoreThan2K", fileType: "swift")
                _ = scissors.tokenizeFileAtPath(path)
            }
            it("should run for files more than 3K lines") {
                let path = reader.pathForFile("TestFileMoreThan3K", fileType: "swift")
                _ = scissors.tokenizeFileAtPath(path)
            }
            it("should distinguish function parameters from shorthand closure ones") {
                let path = reader.pathForFile("TestFileClosureParameters", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForClosureParameters())
                expect(returnContent).to(equal(expectedContent))
            }
            it("should recognize guard statements") {
                let path = reader.pathForFile("TestFileGuard", fileType: "txt")
                let returnContent = scissors.tokenizeFileAtPath(path)
                let expectedContent = FileContent(path: path, components: componentsForGuard())
                expect(returnContent).to(equal(expectedContent))
            }
        }
    }
}
