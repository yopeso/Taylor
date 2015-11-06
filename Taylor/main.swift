//
//  main.swift
//  Taylor
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

import Foundation

let parameters = Arguments()
let printer = Printer(verbosityLevel: parameters.verbosityLevel())
var temper: Temper?

func runTask() {
    printer.printInfo("Taylor \(version)")
    
    guard let rootPath = parameters.rootPath() else {
        printer.printError("No path received.");
        return
    }
    
    runEasterEggIfNeeded()
    
    printer.printInfo("Parameters: \(parameters.arguments)")
    printer.printInfo("Output directory: \(rootPath)")
    
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
    temper?.setLimits(parameters.thresholds())
    setReporters(temper!)
}

func getFileContents() -> [FileContent] {
    let paths = Finder().findFilePaths(parameters: parameters.finderParameters())
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
    let reporters = createReporters(parameters.reporterRepresentations())
    if reporters.count > 0 {
        temper.setReporters(reporters)
    } else {
        printer.printInfo("No reporters were indicated. Default(PMD) reporter will be used.")
    }
}

func createReporters(dictionaryRepresentations: [[String: String]]) -> [Reporter] {
    return dictionaryRepresentations.map { makeReporterFromRepresentation($0) }
}

func makeReporterFromRepresentation(representation: [String : String]) -> Reporter {
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
    if parameters.arguments["type"] != nil { return }
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
    return NSString(data: inputData, encoding:NSUTF8StringEncoding) as! String
}

func runEasterEgg() {
    guard let rootPath = parameters.rootPath() else { exit(EXIT_FAILURE) }
    
    let paths = Finder().findFilePaths(parameters: ["path": [rootPath], "type": ["swift"]])
    let pacman = Pacman(paths: paths)
    pacman.start()
}


runTask()