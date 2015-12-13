//
//  Array+ExtensionsTests.swift
//  Taylor
//
//  Created by Seremet Mihai on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
import Foundation
@testable import TaylorFramework

class CLIReporterTests : QuickSpec {
    
    override func spec() {
        describe("CLIReporter") {
            context("when given an empty array") {
                it("should return empty string") {
                    expect(CLIReporter(results: []).getResultsString()).to(equal(""))
                }
            }
            
            context("when given array") {
                it("should return the output correctly") {
                    let reporter = CLIReporter(results: [ResultOutput(path: "", warnings: 5)])
                    let expectedTable = "=========\n| 5⚠️  ||\n=========\n"
                    let expectedStatistics = "Found 5 violations in 1 files."
                    expect(reporter.getResultsString()).to(equal(expectedTable + expectedStatistics))
                }
            }
        }
    }
}

class StringTypeTests : QuickSpec {
    override func spec() {
        describe("array of strings") {
            context("when asked to find length of the biggest string") {
                it("should return 0 if it is empty") {
                    expect([String]().maxLength).to(equal(0))
                }
                it("should return 0 if there are only empty strings") {
                    expect([""].maxLength).to(equal(0))
                }
                it("should pick the biggest string and return its length") {
                    expect(["testString", "anotherTestString"].maxLength).to(equal(17))
                }
            }
        }
    }
}