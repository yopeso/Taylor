//
//  Array+ExtensionsTests.swift
//  Taylor
//
//  Created by Seremet Mihai on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
import Foundation
@testable import TaylorFramework

class ArrayExtensionsTests : QuickSpec {
    
    override func spec() {
        describe("Array") {
            it("should parralelized map an array") {
                let anArray = ["1", "2", "3", "4", "5"]
                let mappedArray = anArray.pmap({ (element: String) -> Int in
                    return Int(element)!
                })
                for i in 0..<mappedArray.count {
                    expect(mappedArray[i]).to(equal(Int(anArray[i])))
                }
            }
            it("should return empty array") {
                let anArray = [String]()
                let mappedArray = anArray.pmap({ return $0 })
                expect(mappedArray).to(beEmpty())
            }
        }
    }
    
}
