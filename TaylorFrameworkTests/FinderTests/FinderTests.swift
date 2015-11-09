//
//  FinderPathTests.swift
//  Finder
//
//  Created by Simion Schiopu on 8/26/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class FinderTests: QuickSpec {
    override func spec() {
        var finder: Finder!
        var input: Options!
        var mockFileManager: MockFileManager!
        
        beforeEach {
            mockFileManager = MockFileManager()
            finder = Finder(fileManager: mockFileManager, printer: Printer(verbosityLevel: .Error))
        }
        afterEach {
            mockFileManager = nil
            finder = nil
            input = nil
        }
        
        describe("Finder") {
            context("when init with excluded directories and files") {
                it("should return list without excluded paths") {
                    input = ["path": ["/Home/Finder"],
                        "excludes": ["/Home/Finder/FinderTests/*", "/Home/Finder/Finder/Controllers/AccountViewController.swift"],
                        "files": [],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(2))
                    expect(finder.findFilePaths(parameters: input)).to(contain("/Home/Finder/Finder/main.swift", "/Home/Finder/Finder/Controllers/MainViewController.swift"))
                }
                it("should return list without files from all directory with name Controllers") {
                    input = ["path": ["/Home/Finder"],
                        "excludes": [".*Controllers.*"],
                        "files": [],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(2))
                    expect(finder.findFilePaths(parameters: input)).to(contain("/Home/Finder/FinderTests/FinderTests.swift", "/Home/Finder/Finder/main.swift"))
                }
                it("should return list without files from all directory with name contains Tests") {
                    input = ["path": ["/Home/Finder"],
                        "excludes": [".*Tests.*"],
                        "files": [],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(3))
                    expect(finder.findFilePaths(parameters: input)).to(contain("/Home/Finder/Finder/main.swift", "/Home/Finder/Finder/Controllers/AccountViewController.swift", "/Home/Finder/Finder/Controllers/MainViewController.swift"))
                }
            }
            context("when init with wrong excluded directory name") {
                it("should return list with files from all excluded directory name") {
                    input = ["path": ["/Home/Finder"],
                        "excludes": ["Controllers.*"],
                        "files": [],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(4))
                    expect(finder.findFilePaths(parameters: input)).to(contain("/Home/Finder/Finder/main.swift", "/Home/Finder/Finder/Controllers/MainViewController.swift",
                            "/Home/Finder/FinderTests/FinderTests.swift", "/Home/Finder/Finder/Controllers/AccountViewController.swift"))
                }
            }
            context("when init with file paths for include") {
                it("should return list without duplicate paths") {
                    input = ["path": ["/Home/Finder"],
                        "excludes": [],
                        "files": ["/Home/Finder/FinderTests/FinderTests.swift", "/Home/Finder/FinderTests/FinderTests.swift"],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(4))
                    expect(finder.findFilePaths(parameters: input)).to(contain("/Home/Finder/Finder/main.swift", "/Home/Finder/Finder/Controllers/MainViewController.swift",
                            "/Home/Finder/FinderTests/FinderTests.swift", "/Home/Finder/Finder/Controllers/AccountViewController.swift"))
                }
                it("should return explicitly included files no matter what") {
                    input = ["path": ["/Home/Finder"],
                        "excludes": ["/Home/Finder/Finder/*"],
                        "files": ["/Home/Finder/FinderTests/FinderTests.swift"],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input)).to(contain("/Home/Finder/FinderTests/FinderTests.swift"))
                }
            }
            context("when init with empty root Path") {
                it("should return empty array") {
                    input = ["path": [],
                        "excludes": ["/Home/Finder/FinderTests/*"],
                        "files": ["/Home/Finder/FinderTests/FinderTests.swift"],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(0))
                }
            }
            context("when init with empty type") {
                it("should return empty array") {
                    input = ["path": ["/Home/Finder"],
                        "excludes": ["/Home/Finder/FinderTests/*"],
                        "files": ["/Home/Finder/FinderTests/FinderTests.swift"],
                        "type": []]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(0))
                }
            }
            context("when init with wrong included file paths") {
                it("should return empty array") {
                    input = ["path": ["/Home/Finder"],
                        "excludes": ["/Home/Finder/FinderTests/*"],
                        "files": ["/Home/Finder/FinderTests/FinderTests.swift",  "/Home/Finder/FinderTests/Info.plist"],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(0))
                }
            }
            context("when init with wrong root path") {
                it("should return empty array") {
                    input = ["path": ["/Home/Test"],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(0))
                    input = ["path": ["/Home/Finde"],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(0))
                }
            }
            context("when init with empty directory") {
                it("should return empty array") {
                    input = ["path": ["/Home/Test2"],
                        "type": ["swift"]]
                    expect(finder.findFilePaths(parameters: input).count).to(equal(0))
                }
            }
        }
    }
}