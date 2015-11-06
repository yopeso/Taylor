//
//  TooManyParametersRuleTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/30/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class TooManyParametersRuleTests: QuickSpec {
    override func spec() {
        describe("Too Many Parameters Rule") {
            let rule = ExcessiveParameterListRule()
            let component = TestsHelper().parametrizedFunctionComponent
            it("should return false, message and value when there are too many parameters") {
                let badResult = rule.checkComponent(component, atPath: "trololo")
                expect(badResult.isOk).to(beFalse())
                expect(badResult.value).to(equal(4))
                expect(badResult.message).toNot(beNil())
            }
            it("should return true, nil and nil when there are 3 or less parameters") {
                component.components = [Component(type: .Parameter, range: ComponentRange(sl: 10, el: 10))]
                let goodResult = rule.checkComponent(component, atPath: "trololo")
                expect(goodResult.isOk).to(beTrue())
                expect(goodResult.value).to(equal(1))
                expect(goodResult.message).to(beNil())
            }
            it("should return true, nil and nil when there are no parameters") {
                component.components = []
                let veryGoodResult = rule.checkComponent(component, atPath: "trololo")
                expect(veryGoodResult.isOk).to(beTrue())
                expect(veryGoodResult.value).to(equal(0))
                expect(veryGoodResult.message).to(beNil())
            }
            it("should set the priority") {
                rule.priority = 4
                expect(rule.priority).to(equal(4))
            }
        }
    }
}
