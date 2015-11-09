//
//  VerbosityOptionTests.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/29/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class VerbosityOptionTests: QuickSpec {
    override func spec() {
        describe("Verbosity option") {
            
            var verbosity : VerbosityOption!
            
            beforeEach() {
                verbosity = VerbosityOption()
            }
            
            afterEach() {
                verbosity = nil
            }
            
            it("should return verbosity level error if option argument does not match aby abother") {
                verbosity.optionArgument = "something"
                expect(verbosity.verbosityLevelFromOption()).to(equal(VerbosityLevel.Error))
            }
            
            it("should return error if given components have no first element") {
                expect{
                    try verbosity.validateArgumentComponents([String]())
                }.to(throwError())
            }
            
        }
    }
}