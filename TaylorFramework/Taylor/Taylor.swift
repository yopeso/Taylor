//
//  Taylor.swift
//  Taylor
//
//  Created by Alex Culeva on 11/7/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

public final class Taylor {
    let arguments = Arguments()
    let printer: Printer
    
    public init() {
        printer = Printer(verbosityLevel: arguments.verbosityLevel)
    }
    
    /**
     Runs Taylor which initializes all other modules.
    */
    public func run() {
        guard let rootPath = arguments.rootPath else {
            printer.printError("No path received.");
            return
        }
        if inputArgumentsErrorCommited(arguments.arguments) {
            PacmanRunner().runEasterEggPrompt()
        }
        printer.printInfo("Output directory: \(rootPath)")
        
        generateTimeReport(rootPath)
    }
    
    func generateTimeReport(rootPath: String) {
        let timer = Timer()
        timer.start()
        generateReportOnPath(rootPath)
        printer.printInfo("Running time: \(timer.stop())")
    }
    
    func generateReportOnPath(path:Path) {
        let fileContents = getFileContents()
        let reportGenerator = ReportGenerator(arguments: arguments, printer: printer)
        reportGenerator.generateReport(path, fileContents: fileContents)
    }
    
    func getFileContents() -> [FileContent] {
        let paths = Finder().findFilePaths(parameters: arguments.finderParameters)
        let scissors = Scissors(printer: printer)
        
        return parallelizeTokenization(scissors, paths: paths)
    }
    
    func parallelizeTokenization(scissors: Scissors, paths: [String]) -> [FileContent] {
        return paths.pmap { scissors.tokenizeFileAtPath($0) }
    }
    
    func inputArgumentsErrorCommited(arguments: Options) -> Bool {
        return arguments[ErrorKey] != nil
    }
    
}
