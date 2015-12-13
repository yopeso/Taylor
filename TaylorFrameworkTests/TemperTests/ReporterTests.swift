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
            it("should inittilize with type and file name") {
                let reporter = Reporter(type: .Plain, fileName: "just a name")
                expect(reporter).toNot(beNil())
                expect(reporter.type).to(equal(ReporterType.Plain))
                expect(reporter.fileName).to(equal("just a name"))
            }
            it("should inittilize with type") {
                let reporter = Reporter(type: .JSON)
                expect(reporter).toNot(beNil())
                expect(reporter.type).to(equal(ReporterType.JSON))
                expect(reporter.fileName).to(equal("taylor_report.json"))
            }
        }
        describe("ReporterType") {
            it("should return the correct extension") {
                expect(ReporterType.JSON.fileExtension()).to(equal("json"))
                expect(ReporterType.PMD.fileExtension()).to(equal("pmd"))
                expect(ReporterType.Plain.fileExtension()).to(equal("txt"))
                expect(ReporterType.Xcode.fileExtension()).to(equal(""))
            }
            it("should return the correct default file names") {
                expect(ReporterType.JSON.defaultFileName()).to(equal("taylor_report.json"))
                expect(ReporterType.PMD.defaultFileName()).to(equal("taylor_report.pmd"))
                expect(ReporterType.Plain.defaultFileName()).to(equal("taylor_report.txt"))
                expect(ReporterType.Xcode.defaultFileName()).to(equal(""))
            }
            it("should initialize with type name") {
                let type = ReporterType(string: "PMD")
                expect(type).to(equal(ReporterType.PMD))
                let type1 = ReporterType(string: "JSON")
                expect(type1).to(equal(ReporterType.JSON))
                let type2 = ReporterType(string: "XCODE")
                expect(type2).to(equal(ReporterType.Xcode))
                let type3 = ReporterType(string: "PLAIN")
                expect(type3).to(equal(ReporterType.Plain))
                let type4 = ReporterType(string: "gsdgahgailh")
                expect(type4).to(equal(ReporterType.Plain))
            }
        }
    }
}
