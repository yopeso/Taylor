//
//  ExcludesFileOptionTests.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class ExcludesFileOptionTests: QuickSpec {
    override func spec() {
        describe("Rule Customization Option") {
            
            var excludesFileOption : ExcludesFileOption!
            
            beforeEach() {
                excludesFileOption = ExcludesFileOption()
            }
            
            afterEach() {
                excludesFileOption = nil
            }
            
            it("should not set anything to dictionary if excludes is empty") {
                excludesFileOption.optionArgument = MockFileManager().testFile("emptyExcludes", fileType: "yml")
                var testDictionary = Options()
                excludesFileOption.executeOnDictionary(&testDictionary)
                expect(testDictionary).to(beEmpty())
            }
            
        }
    }
}
