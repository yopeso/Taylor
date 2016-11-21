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
        let folderPath = (NSHomeDirectory() as NSString).appendingPathComponent("TemperTestsTempFiles")
        do {
            if FileManager.default.fileExists(atPath: folderPath) { return folderPath }
            try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
        } catch _ {
            return NSHomeDirectory()
        }
        
        return folderPath
    }()
    
    override func spec() {
        
        describe("Output Coordinator") {
            func removeFileAtPaths(_ paths: [String]) {
                for path in paths {
                    FileManager().removeFileAtPath(path)
                }
            }
            afterEach {
                let path = FileManager.default.currentDirectoryPath as NSString
                let jsonPath = path.appendingPathComponent(JSONReporter().defaultFileName())
                let pmdPath = path.appendingPathComponent(PMDReporter().defaultFileName())
                let plainPath = path.appendingPathComponent(PlainReporter().defaultFileName())
                removeFileAtPaths([jsonPath, pmdPath, plainPath, self.reporterPath])
            }
            it("should write the violations in JSON file") {
                let aComponent = TestsHelper().aComponent
                let aRule = TestsHelper().aRule
                let violation = Violation(component: aComponent, rule: aRule, violationData: ViolationData(message: "msg", path: "path", value: 100))
                let filePath = (self.reporterPath as NSString).appendingPathComponent(JSONReporter().defaultFileName())
                OutputCoordinator(filePath: self.reporterPath).writeTheOutput([violation], reporters: [Reporter(JSONReporter())])
                let jsonData = try? Data(contentsOf: URL(string: filePath)!)
                var jsonResult : NSDictionary? = nil
                guard let data = jsonData else {
                    return
                }
                do {
                    jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
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
                expect(FileManager.default.fileExists(atPath: path)).to(beFalse())
            }
            it("should write the violations in XML file") {
                let aComponent = TestsHelper().aComponent
                let aRule = TestsHelper().aRule
                let component = aComponent
                let childComponent = component.makeComponent(type: ComponentType.function, range: ComponentRange(sl: 10, el: 30), name: "justFunction")
                let violation = Violation(component: childComponent, rule: aRule, violationData: ViolationData(message: "msg", path: "path", value: 100))
                let filePath = (self.reporterPath as NSString).appendingPathComponent(PMDReporter().defaultFileName())
                OutputCoordinator(filePath: self.reporterPath).writeTheOutput([violation], reporters: [Reporter(PMDReporter())])
                let xmlData = try? Data(contentsOf: URL(string: filePath)!)
                guard let data = xmlData else {
                    return
                }
                var xml : XMLDocument? = nil
                do {
                    xml = try XMLDocument(data: data, options: 0)
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
                let fileElement = root.elements(forName: "file").first
                expect(fileElement?.attribute(forName: "name")?.stringValue).to(equal("path"))
                let violationElement = fileElement?.elements(forName: "violation").first
                expect(violationElement?.stringValue).to(equal("msg"))
                let element = violation.toXMLElement()
                let violationAttributes = violationElement?.attributes
                let elementAttributes = element.attributes
                expect(violationAttributes).to(equal(elementAttributes))
                let path = "trololo"
                OutputCoordinator(filePath: path).writeTheOutput([violation], reporters: [Reporter(PMDReporter())])
                expect(FileManager.default.fileExists(atPath: path)).to(beFalse())
            }
            it("should write the violations in TXT file") {
                let aComponent = TestsHelper().aComponent
                var folderPath = (NSHomeDirectory() as NSString).appendingPathComponent("TemperTestsTempFiles")
                do {
                    if !FileManager.default.fileExists(atPath: folderPath) {
                        try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
                    }
                } catch _ {
                    folderPath = NSHomeDirectory()
                }
                let filePath = (folderPath as NSString).appendingPathComponent(PlainReporter().defaultFileName())
                let fileContent = FileContent(path: "path", components: [aComponent, aComponent, aComponent, aComponent, aComponent])
                let reporter = PlainReporter()
                let temper = Temper(outputPath: folderPath)
                temper.setReporters([Reporter(reporter)])
                temper.checkContent(fileContent)
                temper.finishTempering()
                expect(FileManager.default.fileExists(atPath: filePath)).to(beTrue())
                let path = "trololo"
                let violation = Violation(component: aComponent, rule: NestedBlockDepthRule(), violationData: ViolationData(message: "msg", path: "path", value: 100))
                OutputCoordinator(filePath: path).writeTheOutput([violation], reporters: [Reporter(PlainReporter())])
                expect(FileManager.default.fileExists(atPath: path)).to(beFalse())
                FileManager.default.removeFileAtPath(folderPath)
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
            it("should catch json errors itself and print error if any problems with json serializing appeared") {
                let messageString = String(bytes: [0xD8, 0x00] as [UInt8],
                                           encoding: String.Encoding.utf16BigEndian)!
                let aComponent = TestsHelper().aComponent
                let aRule = TestsHelper().aRule
                let violation = Violation(component: aComponent, rule: aRule, violationData: ViolationData(message: messageString, path: "path", value: 100))
                expect(JSONCoordinator().writeViolations([violation], atPath: "")).toNot(throwError())
            }
        }
    }
}





