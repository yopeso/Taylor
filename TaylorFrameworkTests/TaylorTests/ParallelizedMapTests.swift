//
//  Array+ExtensionsTests.swift
//  Taylor
//
//  Created by Seremet Mihai on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class ParallelizedMapTests: QuickSpec {
    
    override func spec() {
        describe("Collection") {
            it("should map the elements") {
                let anArray = ["1", "2", "3", "4", "5"]
                let mappedArray = anArray.pmap { Int($0)! }
                
                expect(mappedArray).to(equal([1, 2, 3, 4, 5]))
            }
            it("should map an empty array") {
                let anArray = [String]()
                let mappedArray = anArray.pmap { return $0 }
                expect(mappedArray).to(beEmpty())
            }
        }
    }
    
}
