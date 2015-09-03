//
//  ComponentRangeTests.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import BoundariesKit

class ComponentRangeTests: QuickSpec {
    override func spec() {
        
        let startLine = 3
        let startColumn = 2
        let endLine = 18
        let endColumn = 3
        
        let range = ComponentRange(sl: startLine, sc: startColumn, el: endLine, ec: endColumn)
        
        describe("ComponentRange") {
            it("should contain first and last line, first and last column") {
                expect(range.startLine).to(equal(startLine))
                expect(range.startColumn).to(equal(startColumn))
                expect(range.endLine).to(equal(endLine))
                expect(range.endColumn).to(equal(endColumn))
            }
            
            it("should be equal to a identical range") {
                let identicalRange = ComponentRange(sl: startLine, sc: startColumn, el: endLine, ec: endColumn)
                expect(range).to(equal(identicalRange))
            }
            
            it("should not be equal to a different range") {
                let differentRange = ComponentRange(sl: 0, sc: 0, el: 0, ec: 0)
                expect(range).notTo(equal(differentRange))
            }
        }
    }

}
