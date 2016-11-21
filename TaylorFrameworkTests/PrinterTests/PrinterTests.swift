//
//  PrinterTests.swift
//  PrinterTests
//
//  Created by Andrei Raifura on 9/10/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import TaylorFramework

class FakeReporter : Printing {
    var printedText: String?
    
    init() {}
    
    func printMessage(_ text: String) {
        printedText = text
    }
}

class VerbosityLevelTests: QuickSpec {
    override func spec() {
        describe("Verbosity Level") {
            it("should contain Info, Warning and Error") {
                expect(VerbosityLevel.info).toNot(beNil())
                expect(VerbosityLevel.warning).toNot(beNil())
                expect(VerbosityLevel.error).toNot(beNil())
            }
        }
    }
}

let infoMessage = "Here is an info message"
let warningMessage = "This is an warning"
let errorMessage = "This is an error"

class PrinterTests: QuickSpec {
    
    override func spec() {
        describe("Printer") {
            
            context("when initialized with verbosity level and a reporter") {
                
                let printer = Printer(verbosityLevel:.info, reporter: FakeReporter())
                
                it("should not be nil") {
                    expect(printer).toNot(beNil())
                }
                
                it("should remember the verbosity level") {
                    expect(printer.verbosity).to(equal(VerbosityLevel.info))
                }
            }
            
            context("when verbosity is set to .Info") {
                var reporter: FakeReporter!
                var printer: Printer!
                
                beforeEach {
                    reporter = FakeReporter()
                    printer = Printer(verbosityLevel:.info, reporter: reporter)
                }
                
                it("should output the info messages") {
                    printer.printInfo(infoMessage)
                    expect(reporter.printedText).to(equal(infoMessage))
                }
                
                it("should output the warning messages") {
                    printer.printWarning(warningMessage)
                    expect(reporter.printedText).to(equal(warningMessage))
                }
                
                it("should output the error messages") {
                    printer.printError(errorMessage)
                    expect(reporter.printedText).to(equal(errorMessage))
                }
            }
            
            context("when verbosity is set to .Warning") {
                
                var reporter: FakeReporter!
                var printer: Printer!
                
                beforeEach {
                    reporter = FakeReporter()
                    printer = Printer(verbosityLevel:.warning, reporter: reporter)
                }
                
                it("should not output the info messages") {
                    printer.printInfo(infoMessage)
                    expect(reporter.printedText).to(beNil())
                }
                
                it("should output the warning messages") {
                    printer.printWarning(warningMessage)
                    expect(reporter.printedText).to(equal(warningMessage))
                }
                
                it("should output the error messages") {
                    printer.printError(errorMessage)
                    expect(reporter.printedText).to(equal(errorMessage))
                }
            }
            
            context("when verbosity is set to .Error") {
                
                var reporter: FakeReporter!
                var printer: Printer!
                
                beforeEach {
                    reporter = FakeReporter()
                    printer = Printer(verbosityLevel:.error, reporter: reporter)
                }
                
                it("should not output the info messages") {
                    printer.printInfo(infoMessage)
                    expect(reporter.printedText).to(beNil())
                }
                
                it("should not output the warning messages") {
                    printer.printWarning(warningMessage)
                    expect(reporter.printedText).to(beNil())
                }
                
                it("should output the error messages") {
                    printer.printError(errorMessage)
                    expect(reporter.printedText).to(equal(errorMessage))
                }
            }
            
        }
    }
}
