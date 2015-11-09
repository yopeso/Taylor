//
//  ReporterOptionTests.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class ReporterOptionTests: QuickSpec {
    override func spec() {
        describe("Reporter Option") {
            
            var reporter : ReporterOption!
            
            beforeEach() {
                reporter = ReporterOption()
            }
            
            afterEach() {
                reporter = nil
            }
            
            it("should not throw error for empty arguments components passed to validateArgumentComponents") {
                expect{
                    try reporter.validateArgumentComponents([String]())
                }.toNot(throwError())
            }
            
            it("should set empty value for path key if second component of arguments is nil") {
                reporter.optionArgument = JsonType
                expect(reporter.dictionaryFromArgument()).to(equal(["fileName" : "", "type" : JsonType]))
            }
            
        }
    }
}
