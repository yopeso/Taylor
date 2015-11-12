//
//  TimerTests.swift
//  Taylor
//
//  Created by Seremet Mihai on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
import Foundation
@testable import TaylorFramework

class TimerTests : QuickSpec {
    
    override func spec() {
        describe("Timer") {
            it("should return the execute time") {
                let timer = Timer()
                let executionTime = timer.profile {
                    for var i = 0; i < 1000000; i++ {
                        // Do nothing
                    }
                }
                expect(executionTime).to(beGreaterThan(0))
            }
            it("should return 0 if startDate is't setted") {
                let timer = Timer()
                let executionTime = timer.profile {
                    timer.startDate = nil
                }
                expect(executionTime).to(equal(0))
            }
        }
    }
}