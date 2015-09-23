//
//  main.swift
//  Taylor
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

import Caprice
import Finder
import Scissors
import Temper
import Printer

var printer: Printer!


func run () {
    let caprice = Caprice()
    let arguments = Process.arguments
    let parameters = caprice.processArguments(arguments)
    
    let verbosityLevel = caprice.getVerbosityLevel()
    printer = Printer(verbosityLevel: verbosityLevel)
    guard let rootPath = parameters["path"]?[0] else {
        printer.printError("No path received.");
        return
    }
    
    printer.printInfo("Parameters: \(parameters)")
    printer.printInfo("Output directory: \(rootPath)")
    
    let finder = Finder()
    
    do {
        let paths = try finder.findFilePaths(parameters: parameters)
        let reporters = createReporters(caprice.getReporters())
        
        let temper = Temper(outputPath: rootPath)
        if reporters.count > 0 {
            temper.setReporters(reporters)
        } else {
            printer.printInfo("No reporters were indicated. Default(JSON) reporter will be used.")
        }
        temper.setLimits(caprice.getRuleThresholds())
        let scissors = Scissors(printer: printer)
        for path in paths {
            let content = scissors.tokenizeFileAtPath(path)
            temper.checkContent(content)
        }
        temper.finishTempering()
    } catch _ {
        
    }
}


func createReporters(dictionaryRepresentations: [[String: String]]) -> [Reporter] {
    var reporters = [Reporter]()
    
    for representation in dictionaryRepresentations {
        guard let typeAsString = representation["type"] else {
            printer.printWarning("Reporters: No type was indicated.")
            continue
        }
        
        let type = ReporterType(string: typeAsString)
        if let fileName = representation["fileName"] {
            reporters.append(Reporter(type: type, fileName: fileName))
        } else {
            reporters.append(Reporter(type: type))
        }
    }
    
    return reporters
}

run()
