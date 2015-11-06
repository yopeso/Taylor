//
//  ComponentExtensionsTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/8/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import Taylor

class ComponentExtensionsTests: QuickSpec {
    
    override func spec() {
        
        let nonClassComponent = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 30), name: "function")
        let classComponent = Component(type: ComponentType.Class, range: ComponentRange(sl: 10, el: 30), name: "class")
        let classChildComponent = classComponent.makeComponent(type: ComponentType.Comment, range: ComponentRange(sl: 10, el: 30))
        
        it("should find the parent component of class type, or nil") {
            expect(nonClassComponent.classComponent()).to(beNil())
            expect(classComponent.classComponent()).toNot(beNil())
            expect(classChildComponent.classComponent()).toNot(beNil())
        }
        it("should find the next component") {
            let component = Component(type: ComponentType.If, range: ComponentRange(sl: 1, el: 1))
            let component1 = component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 1, el: 1))
            let component2 = component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 1, el: 1))
            let component3 = component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 1, el: 1))
            expect(component.nextComponent()).to(beNil())
            expect(component1.nextComponent()).to(equal(component2))
            expect(component2.nextComponent()).to(equal(component3))
            expect(component3.nextComponent()).to(beNil())
        }
    }
}
