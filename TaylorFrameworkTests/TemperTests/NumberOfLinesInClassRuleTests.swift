//
//  NumberOfLinesInClassRuleTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/10/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import TaylorFramework

class NumberOfLinesInClassRuleTests: QuickSpec {
    let rule = NumberOfLinesInClassRule()
    override func spec() {
        describe("Number Of Lines In Class Rule") {
            it("should not check the non-class components") {
                let component = Component(type: .For, range: ComponentRange(sl: 0, el: 0), name: nil)
                let result = self.rule.checkComponent(component)
                expect(result.isOk).to(beTrue())
                expect(result.message).to(beNil())
                expect(result.value).to(beNil())
            }
            it("should return true and nil when number of lines in smaller than the limit") {
                let component = TestsHelper().anotherComponent
                let result = self.rule.checkComponent(component)
                expect(result.isOk).to(beTrue())
                expect(result.message).to(beNil())
            }
            it("should return false and message when number of lines in bigger than the limit") {
                let component = TestsHelper().aComponent
                component.name = nil
                let result = self.rule.checkComponent(component)
                expect(result.isOk).to(beFalse())
                expect(result.message).toNot(beNil())
            }
            it("should delete the redundant lines and return the correct number of lines") {
                let component = Component(type: .Class, range: ComponentRange(sl: 1, el: 100))
                component.makeComponent(type: .EmptyLines, range: ComponentRange(sl: 2, el: 5))
                component.makeComponent(type: .Comment, range: ComponentRange(sl: 6, el: 40))
                component.makeComponent(type: .If, range: ComponentRange(sl: 50, el: 60)).makeComponent(type: .Comment, range: ComponentRange(sl: 55, el: 59))
                let result = self.rule.checkComponent(component)
                expect(result.value).to(equal(55))
            }
            it("should set the priority") {
                self.rule.priority = 4
                expect(self.rule.priority).to(equal(4))
            }
        }
    }
}
