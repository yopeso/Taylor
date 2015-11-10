//
//  RuleCustomizationOptionTests.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class RuleCustomizationOptionTests: QuickSpec {
    override func spec() {
        describe("Rule Customization Option") {
            
            var ruleCustomization : RuleCustomizationOption!
            
            beforeEach() {
                ruleCustomization = RuleCustomizationOption()
            }
            
            afterEach() {
                ruleCustomization = nil
            }
            
            it("should return an empty CustomizationRule dictionary if option argument does not contain = symbol") {
                ruleCustomization.optionArgument = "someInvalidRule"
                expect(ruleCustomization.setRuleToDictionary(CustomizationRule())).to(beEmpty())
            }
            
            it("should throw error if the value for rule is not convertible into int") {
                let rule = "ExcessiveClassLength=someValue"
                expect{
                    try ruleCustomization.validateArgumentComponents(rule.componentsSeparatedByString("="))
                }.to(throwError())
            }
            
        }
    }
}