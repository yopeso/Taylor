//
//  OutputCoordinatorTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/3/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import TaylorFramework

class OutputCoordinatorTests : QuickSpec {
    let helper : TestsHelper = TestsHelper()
    lazy var reporterPath : String = {
        let folderPath = (NSHomeDirectory() as NSString).stringByAppendingPathComponent("TemperTestsTempFiles")
        do {
            if NSFileManager.defaultManager().fileExistsAtPath(folderPath) { return folderPath }
            try NSFileManager.defaultManager().createDirectoryAtPath(folderPath, withIntermediateDirectories: false, attributes: nil)
        } catch _ {
            return NSHomeDirectory()
        }
        
        return folderPath
    }()
    
    override func spec() {
        
        describe("Output Coordinator") {
            func removeFileAtPaths(paths: [String]) {
                for path in paths {
                    NSFileManager().removeFileAtPath(path)
                }
            }
            afterEach {
                let path = NSFileManager.defaultManager().currentDirectoryPath as NSString
                let jsonPath = path.stringByAppendingPathComponent(JSONReporter().defaultFileName())
                let pmdPath = path.stringByAppendingPathComponent(PMDReporter().defaultFileName())
                let plainPath = path.stringByAppendingPathComponent(PlainReporter().defaultFileName())
                removeFileAtPaths([jsonPath, pmdPath, plainPath, self.reporterPath])
            }
            it("should write the violations in JSON file") {
                let aComponent = TestsHelper().aComponent
                let aRule = TestsHelper().aRule
                let violation = Violation(component: aComponent, rule: aRule, violationData: ViolationData(message: "msg", path: "path", value: 100))
                let filePath = (self.reporterPath as NSString).stringByAppendingPathComponent(JSONReporter().defaultFileName())
                OutputCoordinator(filePath: self.reporterPath).writeTheOutput([violation], reporters: [Reporter(JSONReporter())])
                let jsonData = NSData(contentsOfFile: filePath)
                var jsonResult : NSDictionary? = nil
                guard let data = jsonData else {
                    return
                }
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                } catch {
                    print("Error while creating the JSON object.")
                }
                guard let result = jsonResult else {
                    return
                }
                if let violations = result["violation"] as? [Dictionary<String, AnyObject>] {
                    if let violationDictionary = violations.first {
                        expect(violation.message).to(equal(violationDictionary["message"] as? String))
                        expect(violation.rule.rule).to(equal(violationDictionary["rule"] as? String))
                        expect(violation.path).to(equal(violationDictionary["path"] as? String))
                        expect(violation.value).to(equal(violationDictionary["value"] as? Int))
                        expect(violation.rule.externalInfoUrl).to(equal(violationDictionary["externalInfoUrl"] as? String))
                        expect(violation.component.name).to(equal(violationDictionary["class"] as? String))
                        expect(violation.component.range).to(equal(ComponentRange.deserialize(violationDictionary)))
                    }
                }
                let path = "trololo"
                OutputCoordinator(filePath: path).writeTheOutput([violation], reporters: [Reporter(JSONReporter())])
                expect(NSFileManager.defaultManager().fileExistsAtPath(path)).to(beFalse())
            }
            it("should write the violations in XML file") {
                let aComponent = TestsHelper().aComponent
                let aRule = TestsHelper().aRule
                let component = aComponent
                let childComponent = component.makeComponent(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 30), name: "justFunction")
                let violation = Violation(component: childComponent, rule: aRule, violationData: ViolationData(message: "msg", path: "path", value: 100))
                let filePath = (self.reporterPath as NSString).stringByAppendingPathComponent(PMDReporter().defaultFileName())
                OutputCoordinator(filePath: self.reporterPath).writeTheOutput([violation], reporters: [Reporter(PMDReporter())])
                let xmlData = NSData(contentsOfFile: filePath)
                guard let data = xmlData else {
                    return
                }
                var xml : NSXMLDocument? = nil
                do {
                    xml = try NSXMLDocument(data: data, options: 0)
                } catch {
                    print("Error while redaing from XML file.")
                }
                guard let result = xml else {
                    return
                }
                guard let root = result.rootElement() else {
                    return
                }
                expect(root.name).to(equal("pmd"))
                let fileElement = root.elementsForName("file").first
                expect(fileElement?.attributeForName("name")?.stringValue).to(equal("path"))
                let violationElement = fileElement?.elementsForName("violation").first
                expect(violationElement?.stringValue).to(equal("msg"))
                let element = violation.toXMLElement()
                let violationAttributes = violationElement?.attributes
                let elementAttributes = element.attributes
                expect(violationAttributes).to(equal(elementAttributes))
                let path = "trololo"
                OutputCoordinator(filePath: path).writeTheOutput([violation], reporters: [Reporter(PMDReporter())])
                expect(NSFileManager.defaultManager().fileExistsAtPath(path)).to(beFalse())
            }
            it("should write the violations in TXT file") {
                let aComponent = TestsHelper().aComponent
                var folderPath = (NSHomeDirectory() as NSString).stringByAppendingPathComponent("TemperTestsTempFiles")
                do {
                    if !NSFileManager.defaultManager().fileExistsAtPath(folderPath) {
                        try NSFileManager.defaultManager().createDirectoryAtPath(folderPath, withIntermediateDirectories: false, attributes: nil)
                    }
                } catch _ {
                    folderPath = NSHomeDirectory()
                }
                let filePath = (folderPath as NSString).stringByAppendingPathComponent(PlainReporter().defaultFileName())
                let fileContent = FileContent(path: "path", components: [aComponent, aComponent, aComponent, aComponent, aComponent])
                let reporter = PlainReporter()
                let temper = Temper(outputPath: folderPath)
                temper.setReporters([Reporter(reporter)])
                temper.checkContent(fileContent)
                temper.finishTempering()
                expect(NSFileManager.defaultManager().fileExistsAtPath(filePath)).to(beTrue())
                let path = "trololo"
                let violation = Violation(component: aComponent, rule: NestedBlockDepthRule(), violationData: ViolationData(message: "msg", path: "path", value: 100))
                OutputCoordinator(filePath: path).writeTheOutput([violation], reporters: [Reporter(PlainReporter())])
                expect(NSFileManager.defaultManager().fileExistsAtPath(path)).to(beFalse())
                NSFileManager.defaultManager().removeFileAtPath(folderPath)
            }
            it("should write the violations in stderr") {
                let aComponent = TestsHelper().aComponent
                let fileContent = FileContent(path: "path", components: [aComponent, aComponent, aComponent, aComponent, aComponent])
                let reporter = XcodeReporter()
                let temper = Temper(outputPath: "")
                temper.setReporters([Reporter(reporter)])
                temper.checkContent(fileContent)
                temper.finishTempering()
            }
        }
    }
}





