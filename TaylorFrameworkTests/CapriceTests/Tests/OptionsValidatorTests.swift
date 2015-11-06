//
//  OptionsValidatorTests.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/29/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class OptionsValidatorTests: QuickSpec {
    override func spec() {
        describe("Options validator") {
            
            var validator : OptionsValidator!
            
            beforeEach() {
                validator = OptionsValidator()
            }
            
            afterEach() {
                validator = nil
            }
            
            it("should throw error if multiple pdm types wa indicated for reporter options") {
                let pmd1 = ReporterOption(argument: "pmd:/path/to/file.pmd")
                let pmd2 = ReporterOption(argument: "pmd:/path/to/file.pmd")
                expect {
                    try validator.validateInformationalOptions([pmd1, pmd2])
                }.to(throwError())
            }
            
            it("should throw error if multiple rule customization of TooManyParameters type are passed") {
                let rule1 = RuleCustomizationOption(argument: "5")
                let rule2 = RuleCustomizationOption(argument: "6")
                expect{
                    try validator.validateInformationalOptions([rule1, rule2])
                }.to(throwError())
            }
            
            it("should not throw error for xcode reporter") {
                let reporter = ReporterOption(argument: "xcode")
                expect {
                    try validator.validateInformationalOptions([reporter])
                }.toNot(throwError())
            }
            
            it("should throw error if multiple xcode reporters requested") {
                let reporter = ReporterOption(argument: "xcode")
                let reporter2 = ReporterOption(argument: "xcode")
                expect {
                    try validator.validateInformationalOptions([reporter, reporter2])
                    }.to(throwError())
            }
            
        }
    }
}