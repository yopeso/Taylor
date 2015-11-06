//
//  NPathComplexityRuleTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/11/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import Taylor

class NPathComplexityRuleTests: QuickSpec {
    let rule = NPathComplexityRule()
    let helper = TestsHelper()
    override func spec() {
        describe("NPath Complexity Rule") {
            it("should set the priority") {
                self.rule.priority = 4
                expect(self.rule.priority).to(equal(4))
            }
            it("should not check the non-function components") {
                let component = Component(type: .For, range: ComponentRange(sl: 0, el: 0))
                let result = self.rule.checkComponent(component, atPath: "path")
                expect(result.isOk).to(beTrue())
                expect(result.message).to(beNil())
                expect(result.value).to(beNil())
            }
            it("should calculate the correct NPath for -while- statement") {
                let result = self.rule.checkComponent(self.helper.whileComponent, atPath: "path")
                expect(result.value).to(equal(7))
            }
            it("should calculate the correct NPath for -if- statement") {
                let result = self.rule.checkComponent(self.helper.ifComponent, atPath: "path")
                expect(result.value).to(equal(243))
            }
            it("should calculate the correct NPath for -if-else- statement") {
                let result = self.rule.checkComponent(self.helper.ifElseComponent, atPath: "path")
                expect(result.value).to(equal(4))
            }
            it("should calculate the correct NPath for -if-elseif- statement") {
                let result = self.rule.checkComponent(self.helper.ifElseIfComponent, atPath: "path")
                expect(result.value).to(equal(3))
            }
            it("should calculate the correct NPath for -repeat- statement") {
                let result = self.rule.checkComponent(self.helper.repeatComponent, atPath: "path")
                expect(result.value).to(equal(5))
            }
            it("should calculate the correct NPath for -for- statement") {
                let result = self.rule.checkComponent(self.helper.forComponent, atPath: "path")
                expect(result.value).to(equal(6))
            }
            it("should calculate the correct NPath for -switch -statement") {
                let result = self.rule.checkComponent(self.helper.switchComponent, atPath: "path")
                expect(result.value).to(equal(8))
            }
            it("should calculate the correct NPath for ?: operator") {
                let result = self.rule.checkComponent(self.helper.ternaryComponent, atPath: "path")
                expect(result.value).to(equal(9))
            }
            it("should calculate the correct NPath for ?? operator") {
                let result = self.rule.checkComponent(self.helper.nilCoalescingComponent, atPath: "path")
                expect(result.value).to(equal(9))
            }
            it("should calculate the correct NPath for nested statements") {
                let result = self.rule.checkComponent(self.helper.nestedComponent, atPath: "path")
                expect(result.value).to(equal(3600))
            }
            it("should calculate the correct NPath for -if-elseif-else- component with nested statements") {
                let result = self.rule.checkComponent(self.helper.ifElseIfElseNestedComponent, atPath: "path")
                expect(result.value).to(equal(26))
            }
        }
    }
}
