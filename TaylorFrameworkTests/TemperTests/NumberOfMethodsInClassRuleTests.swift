//
//  NumberOfMethodsInClassRuleTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/10/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import TaylorFramework

class NumberOfMethodsInClassRuleTests: QuickSpec {
    let rule = NumberOfMethodsInClassRule()
    override func spec() {
        describe("Number Of Methods In Class Rule") {
            it("should not check the non-class components") {
                let component = Component(type: .for, range: ComponentRange(sl: 0, el: 0), name: "blabla")
                let result = self.rule.checkComponent(component)
                expect(result.isOk).to(beTrue())
                expect(result.message).to(beNil())
                expect(result.value).to(beNil())
            }
            it("should return true and nil when number of methods is smaller than the limit") {
                let component = TestsHelper().makeClassComponentWithNrOfMethods(2)
                let result = self.rule.checkComponent(component)
                expect(result.isOk).to(beTrue())
                expect(result.message).to(beNil())
                expect(result.value).to(equal(2))
            }
            it("should return false and message when number of methods is bigger than the limit") {
                let component = TestsHelper().makeClassComponentWithNrOfMethods(12)
                let result = self.rule.checkComponent(component)
                expect(result.isOk).to(beFalse())
                expect(result.message).toNot(beNil())
                expect(result.value).to(equal(12))
            }
            it("should set the priority") {
                self.rule.priority = 4
                expect(self.rule.priority).to(equal(4))
            }
        }
    }
}
