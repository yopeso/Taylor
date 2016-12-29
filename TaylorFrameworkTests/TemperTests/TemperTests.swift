//
//  TmperTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/3/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import TaylorFramework

class TemperTests : QuickSpec {
    let helper = TestsHelper()
    override func spec() {
        afterEach {
            let path = FileManager.default.currentDirectoryPath as NSString
            let filePath = path.appendingPathComponent(JSONReporter().defaultFileName())
            FileManager().removeFileAtPath(filePath)
        }
        it("should detect the violations and create the file/files") {
            let aComponent = TestsHelper().aComponent
            let anotherComponent = TestsHelper().anotherComponent
            aComponent.components = [anotherComponent]

            let filePath = (NSHomeDirectory() as NSString).appendingPathComponent(JSONReporter().defaultFileName())
            let fileContent = FileContent(path: "blablabla", components: [aComponent])
            
            // Tempering
            let temper = Temper(outputPath: NSHomeDirectory())
            temper.setReporters([Reporter(JSONReporter())])
            temper.checkContent(fileContent)
            temper.finishTempering()

            // Read report
            guard let content = try? String(contentsOfFile: filePath) else { return fail() }
            guard let data = content.data(using: .utf8) else { return fail() }
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data,
                                                                     options: JSONSerialization.ReadingOptions.mutableContainers)
                as? [String: AnyObject] else { return fail() }
            guard let result = jsonResult else { return fail() }
            guard let violations = result["violation"] as? [[String: AnyObject]] else { return fail() }
            
            // Check violations
            for violation in violations {
                expect(violation["message"] as? String).toNot(beNil())
                expect(violation["rule"] as? String).toNot(beNil())
                expect(violation["path"] as? String).toNot(beNil())
                expect(violation["priority"] as? Int).toNot(beNil())
                expect(violation["externalInfoUrl"] as? String).toNot(beNil())
                expect(violation["value"] as? Int).toNot(beNil())
                expect(violation["class"] as? String).toNot(beNil())
                expect(ComponentRange.deserialize(violation)).toNot(beNil())
            }
            
            // Cleanup
            FileManager.default.removeFileAtPath(filePath)
        }
        it("should set the rules limits") {
            let temper = Temper(outputPath: FileManager.default.currentDirectoryPath)
            let limits = ["ExcessiveClassLength" : 500, "ExcessiveMethodLength" : 500, "TooManyMethods" : 500,
                          "CyclomaticComplexity" : 500, "NestedBlockDepth" : 500, "NPathComplexity" : 500,
                          "ExcessiveParameterList" : 500]
            temper.setLimits(limits)
            let rules = temper.rules
            for rule in rules {
                for key in limits.keys {
                    if rule.rule == key {
                        expect(rule.limit).to(equal(limits[key]))
                    }
                }
            }
        }
        it("should check the path when initialize the temper") {
            let temper = Temper(outputPath: "gdahdshdsh")
            expect(temper.path).to(equal(FileManager.default.currentDirectoryPath))
        }
        it("should count the violations by priorities") {
            let rule1 = NPathComplexityRule()
            rule1.priority = 1
            rule1.limit = 1
            let rule2 = NumberOfLinesInMethodRule()
            rule2.priority = 2
            rule2.limit = 1
            let rule3 = NestedBlockDepthRule()
            rule3.priority = 3
            rule3.limit = 1
            let rule4 = CyclomaticComplexityRule()
            rule4.priority = 4
            rule4.limit = 1
            let temper = Temper(outputPath: "")
            temper.rules = [rule1, rule2, rule3, rule4]
            let content = FileContent(path: "", components: [self.helper.whileComponent])
            temper.checkContent(content)
            expect(Temper.statistics.violationsWithP1).to(beGreaterThan(0))
            expect(Temper.statistics.violationsWithP2).to(beGreaterThan(0))
            expect(Temper.statistics.violationsWithP3).to(beGreaterThan(0))
        }
    }
}





