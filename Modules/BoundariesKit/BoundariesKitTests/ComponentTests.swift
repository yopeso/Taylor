//
//  ComponentTests.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import BoundariesKit

func getTestRange() -> ComponentRange {
    return ComponentRange(sl: 0, sc: 0, el: 0, ec: 0);
}

class ComponentTests: QuickSpec {
    var component: Component!
    override func spec() {
        
        beforeEach {
            self.component = Component(type: .Class, range: getTestRange(), components: [], name: "Test")
        }
        
        afterEach {
            self.component = nil
        }
        
        describe("Component") {
            context("when initialized with type, range, components and name") {
                it("should not be nil") {
                    expect(self.component).notTo(beNil())
                }
                it("should contain given type, range, components and name") {
                    expect(self.component.type).to(equal(ComponentType.Class))
                    expect(self.component.range).to(equal(getTestRange()))
                    expect(self.component.name).to(equal("Test"))
                    expect(self.component.components).to(equal([]))
                }
            }
            
            context("when initialized with type, range and components") {
                let component = Component(type: .Class, range: getTestRange(), components: [])
                
                it("should not be nil") {
                    expect(component).notTo(beNil())
                }
                
                it("should not contain a name") {
                    expect(component.name).to(beNil())
                }
                
                it("should contain given type, range and components") {
                    expect(component.type).to(equal(ComponentType.Class))
                    expect(component.range).to(equal(getTestRange()))
                    expect(component.components).to(equal([]))
                }
            }
            
            context("when compared with another component") {
                it("should be equal if components are identical") {
                    let identicalComponent = Component(type: .Class, range: getTestRange(), components: [], name: "Test")
                    expect(self.component).to(equal(identicalComponent))
                }
                
                it("should not be equal if components are diffent") {
                    let functionComponent = Component(type: .Function, range: getTestRange(), components: [], name: "Test")
                    expect(self.component).toNot(equal(functionComponent))
                    
                    let componentWithNoName = Component(type: .Function, range: getTestRange(), components: [])
                    expect(self.component).toNot(equal(componentWithNoName))
                    
                    let range = ComponentRange(sl: 0, sc: 0, el: 0, ec: 4)
                    let componentWithDifferentRnage = Component(type: .Class, range: range, components: [])
                    expect(self.component).notTo(equal(componentWithDifferentRnage))
                }
            }
            
        }
    }
    
}
