//
//  ReportGenerator.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/12/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Cocoa

final class ReportGenerator {
    
    var temper: Temper! // Safe to force
    var arguments: Arguments
    var printer: Printer
    
    init(arguments: Arguments, printer: Printer) {
        self.arguments = arguments
        self.printer = printer
    }
    
    func generateReport(_ rootPath: Path, fileContents: [FileContent]) {
        configureTemper(rootPath)
        checkFileContents(fileContents)
    }
    
    func configureTemper(_ rootPath: Path) {
        temper = Temper(outputPath: rootPath)
        temper!.setLimits(arguments.thresholds)
        setReporters(temper!)
    }
    
    func checkFileContents(_ contents: [FileContent]) {
        guard let temper = temper else { return }
        for content in contents {
            temper.checkContent(content)
        }
        printer.printInfo(CLIReporter(results: temper.resultsOutput).getResultsString())
        temper.finishTempering()
    }
    
    func setReporters(_ temper: Temper) {
        let reporters = createReporters(arguments.reporterRepresentations)
        if !reporters.isEmpty {
            temper.setReporters(reporters)
        } else {
            printer.printInfo("No reporters were indicated. Default(PMD) reporter will be used.")
        }
    }
    
    func createReporters(_ dictionaryRepresentations: [OutputReporter]) -> [Reporter] {
        return dictionaryRepresentations.map { makeReporterFromRepresentation($0) }
    }
    
    func makeReporterFromRepresentation(_ representation: OutputReporter) -> Reporter {
        guard let typeAsString = representation[ReporterTypeKey] else {
            printer.printError("Reporters: No type was indicated.")
            exit(EXIT_FAILURE)
        }
        
        return reporterWithType(typeAsString, withRepresentation: representation)
    }
    
    func reporterWithType(_ type: String, withRepresentation representation: OutputReporter) -> Reporter {
        if let fileName = representation[ReporterFileNameKey] {
            return Reporter(type: type, fileName: fileName)
        }
        
        return Reporter(type: type)
    }

}
