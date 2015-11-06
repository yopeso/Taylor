//
//  NestedBlockDepthRuleTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/9/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import TaylorFramework

class NestedBlockDepthRuleTests: QuickSpec {
    var component = TestsHelper().componentForCyclomaticComplexity
    let rule = NestedBlockDepthRule()
    override func spec() {
        describe("Nested Block Depth Rule") {
            it("should return true and nil when the depth is smaller than the limit") {
                let result = self.rule.checkComponent(self.component, atPath: "path")
                expect(result.isOk).to(beTrue())
                expect(result.message).to(beNil())
                expect(result.value).to(equal(3))
            }
            it("should return false and message when the depth is bigger than the limit") {
                self.component = TestsHelper().addComponentsInDepthToComponent(self.component)
                self.component.name = nil
                let result = self.rule.checkComponent(self.component, atPath: "path")
                expect(result.isOk).to(beFalse())
                expect(result.message).toNot(beNil())
                expect(result.value).to(equal(10))
            }
            it("should not check the non-function components") {
                let component = Component(type: .For, range: ComponentRange(sl: 0, el: 0))
                let result = self.rule.checkComponent(component, atPath: "path")
                expect(result.isOk).to(beTrue())
                expect(result.message).to(beNil())
                expect(result.value).to(beNil())
            }
            it("should set the priority") {
                self.rule.priority = 4
                expect(self.rule.priority).to(equal(4))
            }
        }
    }
}
