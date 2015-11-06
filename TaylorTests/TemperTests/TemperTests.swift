//
//  TmperTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/3/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation
import BoundariesKit
import Nimble
import Quick
@testable import Temper

class TemperTests : QuickSpec {
    let helper = TestsHelper()
    override func spec() {
        afterEach {
            let path = NSFileManager.defaultManager().currentDirectoryPath as NSString
            let filePath = path.stringByAppendingPathComponent(ReporterType.JSON.defaultFileName())
            NSFileManager().removeFileAtPath(filePath)
        }
        it("should detect the violations and create the file/files") {
            let aComponent = TestsHelper().aComponent
            let anotherComponent = TestsHelper().anotherComponent
            let path =  NSHomeDirectory() as NSString
            let filePath = path.stringByAppendingPathComponent(ReporterType.JSON.defaultFileName())
            let temper = Temper(outputPath: (path as String))
            aComponent.components = [anotherComponent]
            let content = FileContent(path: "blablabla", components: [aComponent])
            let reporter = Reporter(type: .JSON, fileName: ReporterType.JSON.defaultFileName())
            temper.setReporters([reporter])
            temper.checkContent(content)
            temper.finishTempering()
            let jsonData = NSData(contentsOfFile: filePath)
            guard let data = jsonData else {
                return
            }
            var jsonResult : NSDictionary? = nil
            do {
                jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            } catch {
                print("Error while creating the JSON object.")
            }
            guard let result = jsonResult else {
                return
            }
            if let violations = result["violation"] as? [Dictionary<String, AnyObject>] {
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
            }
        }
        it("should set the rules limits") {
            let temper = Temper(outputPath: NSFileManager.defaultManager().currentDirectoryPath)
            let limits = ["ExcessiveClassLength" : 500, "ExcessiveMethodLength" : 500, "TooManyMethods" : 500,
                          "CyclomaticComplexity" : 500, "NestedBlockDepth" : 500, "NPathComplexity" : 500, "ExcessiveParameterList" : 500]
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
            expect(temper.path).to(equal(NSFileManager.defaultManager().currentDirectoryPath))
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
            expect(Temper.violationsWithP1).to(beGreaterThan(0))
            expect(Temper.violationsWithP2).to(beGreaterThan(0))
            expect(Temper.violationsWithP3).to(beGreaterThan(0))
        }
    }
}





