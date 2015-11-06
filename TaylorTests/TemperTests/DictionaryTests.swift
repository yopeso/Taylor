//
//  DictionaryTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/3/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import Taylor

class DictionaryTests : QuickSpec {
    override func spec() {
        describe("Dictionary") {
            it("should merge another dictionary") {
                var dictionary1 = ["key1" : "value1", "key2" : "value2"]
                let dictionary2 = ["key3" : "value3"]
                let dictionary3 = ["key1" : "value1", "key2" : "value2", "key3" : "value3"]
                dictionary1 += dictionary2
                expect(dictionary1).to(equal(dictionary3))
            }
        }
    }
}
