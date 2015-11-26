//
//  UtilitiesTests.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import TaylorFramework

class UtilitiesTests: QuickSpec {

    override func spec() {
        var lhs: String?
        var rhs: String?
        
        describe("String Optionals Equality operator") {
            
            beforeEach {
                lhs = nil
                rhs = nil
            }
            
            it("should return true if both operands are nil") {
                expect(lhs ~== rhs).to(beTrue())
            }
            
            it("should return false if one operand is nil and onther has a value") {
                rhs = nil
                lhs = "bla bla"
                expect(lhs ~== rhs).to(beFalse())
                
                rhs = "bla bla"
                lhs = nil
                expect(lhs ~== rhs).to(beFalse())
            }

            it("should return false if values are different") {
                rhs = "value1"
                lhs = "value2"
                expect(lhs ~== rhs).to(beFalse())
            }
            
            it("should return true when values are equal") {
                rhs = "value1"
                lhs = "value1"
                expect(lhs ~== rhs).to(beTrue())
            }
        }
        
        describe("String Optionals Inequality operator") {
            
            beforeEach {
                lhs = nil
                rhs = nil
            }
            
            it("should return false if both operands are nil") {
                expect(lhs !~== rhs).to(beFalse())
            }
            
            it("should return true if values are equal") {
                rhs = "value1"
                lhs = "value2"
                expect(lhs !~== rhs).to(beTrue())
            }
            
            it("should return true if one operand is nil and onther has a value") {
                rhs = nil
                lhs = "bla bla"
                expect(lhs !~== rhs).to(beTrue())
                
                rhs = "bla bla"
                lhs = nil
                expect(lhs !~== rhs).to(beTrue())
            }
            
            it("should return false when values are equal") {
                rhs = "value1"
                lhs = "value1"
                expect(lhs !~== rhs).to(beFalse())
            }
        }
    }

}
