//
//  ViolationTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/3/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import TaylorFramework


class ViolationTests : QuickSpec {
    let helper : TestsHelper = TestsHelper()
    let aComponent = TestsHelper().anotherComponent
    let aRule = TestsHelper().aRule
    
    override func spec() {
        var violation: Violation!
        beforeEach() {
            violation = Violation(component: self.aComponent, rule: self.aRule, violationData: ViolationData(message: "msg", path: "path", value: 100))
        }
        describe("Violation") {
            it("should instantiate from component, rule, message and path") {
                expect(violation.component).to(equal(self.aComponent))
                expect(violation.rule.rule).to(equal(self.aRule.rule))
                expect(violation.message).to(equal("msg"))
                expect(violation.path).to(equal("path"))
                expect(violation.rule.priority).to(equal(self.aRule.priority))
                expect(violation.rule.externalInfoUrl).to(equal(self.aRule.externalInfoUrl))
            }
            it("should return the correct dictionary") {
                let violationDictionary = violation.toDictionary()
                expect(violation.message).to(equal(violationDictionary["message"] as? String))
                expect(violation.rule.rule).to(equal(violationDictionary["rule"] as? String))
                expect(violation.path).to(equal(violationDictionary["path"] as? String))
                expect(violation.rule.priority).to(equal(violationDictionary["priority"] as? Int))
                expect(violation.rule.externalInfoUrl).to(equal(violationDictionary["externalInfoUrl"] as? String))
                expect(violation.value).to(equal(violationDictionary["value"] as? Int))
                expect(violation.component.name).to(equal(violationDictionary["class"] as? String))
                let range = ComponentRange.deserialize(violationDictionary)
                expect(violation.component.range).to(equal(range))
            }
            it("should return the correct dictionary from function component") {
                let classComponent = Component(type: .class, range: ComponentRange(sl: 0, el: 0), name: "TheClass")
                let component = self.helper.ifComponent
                component.parent = classComponent
                let violation = Violation(component: component, rule: self.aRule, violationData: ViolationData(message: "msg", path: "path", value: 100))
                let violationDictionary = violation.toDictionary()
                expect(violation.message).to(equal(violationDictionary["message"] as? String))
                expect(violation.rule.rule).to(equal(violationDictionary["rule"] as? String))
                expect(violation.path).to(equal(violationDictionary["path"] as? String))
                expect(violation.rule.priority).to(equal(violationDictionary["priority"] as? Int))
            expect(violation.rule.externalInfoUrl).to(equal(violationDictionary["externalInfoUrl"] as? String))
                expect(violation.value).to(equal(violationDictionary["value"] as? Int))
                expect(violation.component.name).to(equal(violationDictionary["method"] as? String))
                let range = ComponentRange.deserialize(violationDictionary)
                expect(violation.component.range).to(equal(range))
            }
            it("should return the correct XML element") {
                let element = violation.toXMLElement()
                expect(element.stringValue).to(equal("msg"))
                let attributes = element.attributes
                expect(attributes).to(contain((XMLNode.attribute(withName: "rule", stringValue: violation.rule.rule) as? XMLNode)!))
                if let classComponent = violation.component.classComponent() {
                    if let name = classComponent.name {
                        expect(attributes).to(contain((XMLNode.attribute(withName: "class", stringValue: name) as? XMLNode)!))
                    }
                }
                expect(attributes).to(contain((XMLNode.attribute(withName: "externalInfoUrl", stringValue: violation.rule.externalInfoUrl) as? XMLNode)!))
                expect(attributes).to(contain((XMLNode.attribute(withName: "priority", stringValue: String(violation.rule.priority)) as? XMLNode)!))
                if self.aComponent.type == ComponentType.function {
                    if let name = self.aComponent.name {
                        expect(attributes).to(contain((XMLNode.attribute(withName: "method", stringValue: name) as? XMLNode)!))
                    }
                }
                expect(attributes).to(contain((XMLNode.attribute(withName: "beginline", stringValue: String(self.aComponent.range.startLine)) as? XMLNode)!))
                expect(attributes).to(contain((XMLNode.attribute(withName: "endline", stringValue: String(self.aComponent.range.endLine)) as? XMLNode)!))
            }
            it("should remove backslashes from path when creating the violation") {
                var containsBackslash = false
                for character in violation.path.characters {
                    if character == "\\" {
                        containsBackslash = true
                    }
                }
                expect(containsBackslash).to(beFalse())
            }
            it("should return the correct error string for stderr") {
                let violation = Violation(component: self.aComponent, rule: self.aRule, violationData: ViolationData(message: "msg", path: "thepath", value: 50))
                let errorString = violation.errorString
                expect(errorString).to(equal("thepath:\(self.aComponent.range.startLine):0: warning: \(self.aRule.rule)(P\(self.aRule.priority)):msg\n"))
                
            }
        }
    }
}
