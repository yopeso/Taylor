//
//  ArgumentsTests.swift
//  Finder
//
//  Created by Simion Schiopu on 9/1/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
import Printer
@testable import Finder

class ParametersTests: QuickSpec {
    
    override func spec() {
        var printer: ErrorPrinter!
        
        beforeEach {
            printer = ErrorPrinter(printer: Printer(verbosityLevel: .Error))
        }
        
        afterEach {
            printer = nil
        }
        
        describe("Arguments") {
            
            context("when init with empty path") {
                it("should return nil") {
                    expect(Parameters(dictionary: ["path": []], printer: printer)).to(beNil())
                    expect(Parameters(dictionary: ["path": [""]], printer: printer)).to(beNil())
                }
                
            }
            
            context("when init with empty type") {
                it("should return nil") {
                    expect(Parameters(dictionary: ["path": ["/Home"], "type": []], printer: printer)).to(beNil())
                    expect(Parameters(dictionary: ["path": ["/Home"], "type": [""]], printer: printer)).to(beNil())
                }
            }
            
            context("when init with full dictionary") {
                var parameters: Parameters!
                
                beforeEach() {
                    parameters = Parameters(dictionary: ["path": ["/Home"],
                        "excludes": ["/Home/*", "/Home/test.swift"],
                        "files": ["/Home/test2.swift", "/Home/test3.swift"],
                        "type": ["swift"]], printer: printer)
                }
                
                it("should set all parameters with values from dictionary") {
                    expect(parameters.rootPath).to(equal("/Home"))
                    expect(parameters.excludes.count).to(equal(2))
                    expect(parameters.excludes).to(contain("/Home/*", "/Home/test.swift"))
                    expect(parameters.files.count).to(equal(2))
                    expect(parameters.files).to(contain("/Home/test2.swift", "/Home/test3.swift"))
                    expect(parameters.type).to(equal("swift"))
                }
            }
        }
    }
}