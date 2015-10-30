//
//  IntegrationTests.swift
//  IntegrationTests
//
//  Created by Andrei Raifura on 9/24/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
import Temper
import Scissors
import BoundariesKit

class IntegrationTests: QuickSpec {
    override func spec() {
        describe("Integration tests") {
            it("should pass") {
                expect(true).to(beTruthy())
            }
        }
    }
}

