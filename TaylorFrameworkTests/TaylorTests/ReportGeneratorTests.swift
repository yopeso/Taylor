//
//  ReportGeneratorTests.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/12/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
import Foundation
@testable import TaylorFramework

class ReportGeneratorTests : QuickSpec {
    
    override func spec() {
        describe("Report generator") {
            
            var reportGenerator: ReportGenerator!
            
            beforeEach {
                reportGenerator = ReportGenerator(arguments: Arguments(), printer: Printer(verbosityLevel: .Info))
            }
            
            afterEach {
                reportGenerator = nil
            }
            
            it("should initialize reporter with default report file name if it is not gived") {
                let type = ReporterType(string: "json")
                let outputReporter = [ReporterTypeKey : "json"]
                let resultReporter = reportGenerator.reporterWithType(type, withRepresentation: outputReporter)
                let expectedFileName = "taylor_report.json"
                expect(resultReporter.fileName).to(equal(expectedFileName))
            }
            
        }
    }
}