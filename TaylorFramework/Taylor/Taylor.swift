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
    var temper: Temper!
    
    public init() {
        printer = Printer(verbosityLevel: arguments.verbosityLevel)
    }
    
    /**
     Runs Taylor which initializes all other modules.
    */
    public func run() {
        printer.printInfo("Taylor \(version)")
        
        guard let rootPath = arguments.rootPath else {
            printer.printError("No path received.");
            return
        }
        
        runEasterEggIfNeeded()
        printParameters(arguments.arguments, directory: rootPath)
        
        
        generateTimeReport(rootPath)
    }
    
    func printParameters(parameters: Options, directory dir: String) {
        printer.printInfo("Parameters: \(arguments.arguments)")
        printer.printInfo("Output directory: \(dir)")
    }
    
    func generateTimeReport(rootPath: String) {
        let timer = Timer()
        timer.start()
        generateReport(rootPath)
        printer.printInfo("Running time: \(timer.stop())")
    }
    
    func generateReport(rootPath: String) {
        configureTemper(rootPath)
        checkFileContents(getFileContents())
    }
    func configureTemper(rootPath: String) {
        temper = Temper(outputPath: rootPath)
        temper?.setLimits(arguments.thresholds)
        setReporters(temper!)
    }
    func getFileContents() -> [FileContent] {
        let paths = Finder().findFilePaths(parameters: arguments.finderParameters)
        let scissors = Scissors(printer: printer)
        
        return parallelizeTokenization(scissors, paths: paths)
    }
    func checkFileContents(contents: [FileContent]) {
        guard let temper = temper else { return }
        
        for content in contents {
            temper.checkContent(content)
        }
        temper.finishTempering()
    }
    func parallelizeTokenization(scissors: Scissors, paths: [String]) -> [FileContent] {
        return paths.pmap { scissors.tokenizeFileAtPath($0) }
    }
    // MARK: Reporters
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
        guard let typeAsString = representation["type"] else {
            printer.printError("Reporters: No type was indicated.")
            exit(EXIT_FAILURE)
        }
        
        let type = ReporterType(string: typeAsString)
        if let fileName = representation["fileName"] {
            return Reporter(type: type, fileName: fileName)
        } else {
            return Reporter(type: type)
        }
    }
    // MARK: Easter Egg
    func runEasterEggIfNeeded() {
        if arguments.arguments["type"] != nil { return }
        defer { exit(EXIT_FAILURE) }
        
        printer.printError("Taylor is mad! Would you like to play with her(it)? (Y/N)")
        if formatInputString(input()).uppercaseString == "Y" {
            runEasterEgg()
        } else {
            printer.printError("O Kay! Next time :)")
        }
    }
    func formatInputString(string: String) -> String {
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
    }
    func input() -> String {
        let keyboard = NSFileHandle.fileHandleWithStandardInput()
        let inputData = keyboard.availableData
        return NSString(data: inputData, encoding: NSUTF8StringEncoding) as! String
    }
    func runEasterEgg() {
        guard let rootPath = arguments.rootPath else { exit(EXIT_FAILURE) }
        
        let paths = Finder().findFilePaths(parameters: ["path": [rootPath], "type": ["swift"]])
        let pacman = Pacman(paths: paths)
        pacman.start()
    }
}
