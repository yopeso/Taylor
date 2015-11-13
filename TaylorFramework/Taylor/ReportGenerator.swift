//
//  ReportGenerator.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/12/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Cocoa

class ReportGenerator {
    
    var temper: Temper!
    var arguments: Arguments
    var printer: Printer
    
    init(arguments: Arguments, printer: Printer) {
        self.arguments = arguments
        self.printer = printer
    }
    
    func generateReport(rootPath: Path, fileContents:[FileContent]) {
        configureTemper(rootPath)
        checkFileContents(fileContents)
    }
    
    func configureTemper(rootPath: Path) {
        temper = Temper(outputPath: rootPath)
        temper?.setLimits(arguments.thresholds)
        setReporters(temper!)
    }
    
    func checkFileContents(contents: [FileContent]) {
        guard let temper = temper else { return }
        for content in contents {
            temper.checkContent(content)
        }
        printer.printInfo(CLIReporter(results: temper.resultsOutput).getResultsString())
        temper.finishTempering()
    }
    
    func setReporters(temper: Temper) {
        let reporters = createReporters(arguments.reporterRepresentations)
        if !reporters.isEmpty {
            temper.setReporters(reporters)
        } else {
            printer.printInfo("No reporters were indicated. Default(PMD) reporter will be used.")
        }
    }
    
    func createReporters(dictionaryRepresentations: [OutputReporter]) -> [Reporter] {
        return dictionaryRepresentations.map { makeReporterFromRepresentation($0) }
    }
    
    func makeReporterFromRepresentation(representation: OutputReporter) -> Reporter {
        guard let typeAsString = representation[ReporterTypeKey] else {
            printer.printError("Reporters: No type was indicated.")
            exit(EXIT_FAILURE)
        }
        
        return reporterWithType(ReporterType(string: typeAsString), withRepresentation: representation)
    }
    
    func reporterWithType(type: ReporterType, withRepresentation representation: OutputReporter) -> Reporter {
        if let fileName = representation[ReporterFileNameKey] {
            return Reporter(type: type, fileName: fileName)
        }
        
        return Reporter(type: type)
    }

}
