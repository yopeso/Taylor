//
//  Taylor.swift
//  Taylor
//
//  Created by Alex Culeva on 11/7/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

public struct Taylor {
    
    public init() { }
    
    /**
     Runs Taylor which initializes all other modules.
     */
    public func run() {
        guard let arguments = processArguments() else { return }
        if arguments.arguments.isEmpty || arguments.arguments[ErrorKey] != nil {
            handleError("Invalid arguments.")
            return
        }
        let printer = Printer(verbosityLevel: arguments.verbosityLevel)
        guard let rootPath = arguments.rootPath else {
            printer.printError("No path received.")
            return
        }
        printer.printInfo("Output directory: \(rootPath)")
        
        generateTimeReport(rootPath, printer: printer, arguments: arguments)
    }
    
    func processArguments() -> Arguments? {
        do {
            return try Arguments()
        } catch CommandLineError.invalidArguments(let errorMessage) {
            handleError(errorMessage)
        } catch CommandLineError.invalidInformationalOption(let errorMessage) {
            handleError(errorMessage)
        } catch CommandLineError.invalidOption(let errorMessage) {
            handleError(errorMessage)
        } catch CommandLineError.abuseOfOptions(let errorMessage) {
            handleError(errorMessage)
        } catch { }
        return nil
    }
    
    func handleError(_ errorMessage: String) {
        print(errorMessage)
        PacmanRunner().runEasterEggPrompt()
    }
    
    func generateTimeReport(_ rootPath: String, printer: Printer, arguments: Arguments) {
        let timer = Timer()
        timer.start()
        generateReportOnPath(rootPath, arguments: arguments, printer: printer)
        let time = String(format: "%.2f", timer.stop())
        printer.printInfo("Running time: \(time) seconds")
    }
    
    func generateReportOnPath(_ path: Path, arguments: Arguments, printer: Printer) {
        let fileContents = getFileContents(arguments)
        let reportGenerator = ReportGenerator(arguments: arguments, printer: printer)
        reportGenerator.generateReport(path, fileContents: fileContents)
    }
    
    func getFileContents(_ arguments: Arguments) -> [FileContent] {
        let paths = Finder().findFilePaths(parameters: arguments.finderParameters)
        
        return parallelizeTokenization(paths)
    }
    
    func parallelizeTokenization(_ paths: [String]) -> [FileContent] {
        let scissors = Scissors()
        return paths.pmap { scissors.tokenizeFileAtPath($0) }
    }
}
