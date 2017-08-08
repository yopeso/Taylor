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
    let helper: TestsHelper = TestsHelper()
    
    override func spec() {
        
        describe("Output Coordinator") {
            it("should write the violations in JSON file") {
                let violation = Violation(component: TestsHelper().aComponent,
                                          rule: TestsHelper().aRule,
                                          violationData: ViolationData(message: "msg", path: "path", value: 100))
                
                // Create report
                let filePath = (NSHomeDirectory() as NSString).appendingPathComponent(JSONReporter().defaultFileName())
                OutputCoordinator(filePath: NSHomeDirectory()).writeTheOutput([violation], reporters: [Reporter(JSONReporter())])
                
                // Read report
                guard let content = try? String(contentsOfFile: filePath) else { return fail() }
                guard let data = content.data(using: .utf8) else { return fail() }
                guard let jsonResult = try? JSONSerialization.jsonObject(with: data,
                                                                         options: JSONSerialization.ReadingOptions.mutableContainers)
                    as? [String: AnyObject] else { return fail() }
                guard let result = jsonResult else { return fail() }
                guard let violations = result["violation"] as? [[String: AnyObject]] else { return fail() }
                guard let violationDictionary = violations.first else { return fail() }
                
                // Check report
                expect(violation.message).to(equal(violationDictionary["message"] as? String))
                expect(violation.rule.rule).to(equal(violationDictionary["rule"] as? String))
                expect(violation.path).to(equal(violationDictionary["path"] as? String))
                expect(violation.value).to(equal(violationDictionary["value"] as? Int))
                expect(violation.rule.externalInfoUrl).to(equal(violationDictionary["externalInfoUrl"] as? String))
                expect(violation.component.name).to(equal(violationDictionary["class"] as? String))
                expect(violation.component.range).to(equal(ComponentRange.deserialize(violationDictionary)))
                
                // Cleanup
                FileManager.default.removeFileAtPath(filePath)
            }
            it("should write the violations in XML file") {
                let aComponent = TestsHelper().aComponent
                let aRule = TestsHelper().aRule
                let component = aComponent
                let childComponent = component.makeComponent(type: ComponentType.function,
                                                             range: ComponentRange(sl: 10, el: 30),
                                                             name: "justFunction")
                let violation = Violation(component: childComponent,
                                          rule: aRule,
                                          violationData: ViolationData(message: "msg", path: "path", value: 100))
                
                // Create report
                let filePath = (NSHomeDirectory() as NSString).appendingPathComponent(PMDReporter().defaultFileName())
                OutputCoordinator(filePath: NSHomeDirectory()).writeTheOutput([violation], reporters: [Reporter(PMDReporter())])
                
                // Read report
                guard let content = try? String(contentsOfFile: filePath) else { return fail() }
                guard let xml = try? XMLDocument(xmlString: content, options: []) else { return fail() }
                guard let root = xml.rootElement() else { return fail() }
                
                // Check report
                expect(root.name).to(equal("pmd"))
                
                let fileElement = root.elements(forName: "file").first!
                expect(fileElement.attribute(forName: "name")?.stringValue).to(equal("path"))
                
                let violationElement = fileElement.elements(forName: "violation").first!
                expect(violationElement.stringValue).to(equal("msg"))
                
                let element = violation.toXMLElement()
                let violationAttributes = violationElement.attributes
                let elementAttributes = element.attributes
                expect(violationAttributes).to(equal(elementAttributes))
                
                // Cleanup
                FileManager.default.removeFileAtPath(filePath)
            }
            it("shouldn't create report when give a wrong path") {
                let violation = Violation(component: TestsHelper().aComponent,
                                          rule: TestsHelper().aRule,
                                          violationData: ViolationData(message: "msg", path: "path", value: 100))
                let path = "trololo"
                OutputCoordinator(filePath: path).writeTheOutput([violation], reporters: [Reporter(PMDReporter())])
                expect(FileManager.default.fileExists(atPath: path)).to(beFalse())
                OutputCoordinator(filePath: path).writeTheOutput([violation], reporters: [Reporter(JSONReporter())])
                expect(FileManager.default.fileExists(atPath: path)).to(beFalse())
            }
            it("should write the violations in TXT file") {
                let aComponent = TestsHelper().aComponent
                let filePath = (NSHomeDirectory() as NSString).appendingPathComponent(PlainReporter().defaultFileName())
                let fileContent = FileContent(path: "path", components: [aComponent, aComponent, aComponent, aComponent, aComponent])
                let reporter = PlainReporter()
                let temper = Temper(outputPath: NSHomeDirectory())
                temper.setReporters([Reporter(reporter)])
                temper.checkContent(fileContent)
                temper.finishTempering()
                expect(FileManager.default.fileExists(atPath: filePath)).to(beTrue())
                let path = "trololo"
                let violation = Violation(component: aComponent,
                                          rule: NestedBlockDepthRule(),
                                          violationData: ViolationData(message: "msg", path: "path", value: 100))
                OutputCoordinator(filePath: path).writeTheOutput([violation], reporters: [Reporter(PlainReporter())])
                expect(FileManager.default.fileExists(atPath: path)).to(beFalse())
                
                // Cleanup
                FileManager.default.removeFileAtPath(filePath)
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
                let violation = Violation(component: aComponent,
                                          rule: aRule,
                                          violationData: ViolationData(message: messageString, path: "path", value: 100))
                expect(JSONCoordinator().writeViolations([violation], atPath: "")).toNot(throwError())
            }
        }
    }
}





