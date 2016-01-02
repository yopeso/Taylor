//
//  ReporterTests.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Nimble
import Quick
@testable import TaylorFramework

class ReporterTests: QuickSpec {
    override func spec() {
        describe("Reporter") {
            it("should initialize with type and file name") {
                let reporter = Reporter(type: "", fileName: "just a name")
                expect(reporter).toNot(beNil())
                expect(reporter.concreteReporter is PlainReporter).to(beTrue())
                expect(reporter.fileName).to(equal("just a name"))
            }
            it("should initialize with type") {
                let reporter = Reporter(type: "JSON")
                expect(reporter).toNot(beNil())
                expect(reporter.concreteReporter is JSONReporter).to(beTrue())
                expect(reporter.fileName).to(equal("taylor_report.json"))
            }
        }
        describe("ReporterType") {
            it("should return the correct extension") {
                expect(JSONReporter().fileExtension()).to(equal("json"))
                expect(PMDReporter().fileExtension()).to(equal("pmd"))
                expect(PlainReporter().fileExtension()).to(equal("txt"))
                expect(XcodeReporter().fileExtension()).to(equal(""))
            }
            it("should return the correct default file names") {
                expect(JSONReporter().defaultFileName()).to(equal("taylor_report.json"))
                expect(PMDReporter().defaultFileName()).to(equal("taylor_report.pmd"))
                expect(PlainReporter().defaultFileName()).to(equal("taylor_report.txt"))
                expect(XcodeReporter().defaultFileName()).to(equal(""))
            }
            it("should initialize with type name") {
                let type = Reporter(type:"PMD")
                expect(type.concreteReporter is PMDReporter).to(beTrue())
                let type1 = Reporter(type:"JSON")
                expect(type1.concreteReporter is JSONReporter).to(beTrue())
                let type2 = Reporter(type:"XCODE")
                expect(type2.concreteReporter is XcodeReporter).to(beTrue())
                let type3 = Reporter(type:"PLAIN")
                expect(type3.concreteReporter is PlainReporter).to(beTrue())
                let type4 = Reporter(type:"gsdgahgailh")
                expect(type4.concreteReporter is PlainReporter).to(beTrue())
            }
        }
    }
}
