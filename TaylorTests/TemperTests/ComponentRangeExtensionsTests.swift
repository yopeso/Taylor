//
//  ComponentExtensionsTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/8/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import BoundariesKit
import Nimble
import Quick
@testable import Temper

class ComponentRangeExtensionsTests: QuickSpec {
    var range : ComponentRange = ComponentRange(sl: 10, el: 30)
    override func spec() {
        it("should serialize object to dictionary") {
            let serializedDictionary = self.range.serialize()
            expect(serializedDictionary["startLine"] as? Int).to(equal(self.range.startLine))
            expect(serializedDictionary["endLine"] as? Int).to(equal(self.range.endLine))
        }
        it("should deserialize dictionary to object") {
            let serializedDictionary = self.range.serialize()
            let deserializedObject = ComponentRange.deserialize(serializedDictionary)
            expect(self.range.startLine).to(equal(deserializedObject?.startLine))
            expect(self.range.endLine).to(equal(deserializedObject?.endLine))
        }
        it("should return correct attributes") {
            let attributes = self.range.XMLAttributes()
            expect(attributes[0].stringValue).to(equal(String(self.range.startLine)))
            expect(attributes[1].stringValue).to(equal(String(self.range.endLine)))
        }
    }
}
