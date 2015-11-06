//
//  RulesTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/3/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import BoundariesKit
import Nimble
import Quick
@testable import Temper

class RulesTests : QuickSpec {
    let helper = TestsHelper()
    override func spec() {
        describe("RulesFactory") {
            it("should return the rules") {
                let rules = RulesFactory().getRules()
                expect(rules.count).to(equal(7))
            }
        }
    }
}