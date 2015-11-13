//
//  ResultPrinter.swift
//  Taylor
//
//  Created by Alex Culeva on 11/10/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

typealias ResultOutput = (path: String, warnings: Int)

final class CLIReporter {
    let results: [ResultOutput]
    let printer: Printer
    
    init(results: [ResultOutput], printer: Printer) {
        self.results = results
        self.printer = printer
    }
    
    func outputResults() {
        guard results.count > 0 else { return }
        let numberOfExtraCharacters = 7
        let maximalPathChars = results.map { $0.path }.maxLength
        let totalChars = maximalPathChars + numberOfExtraCharacters
        print("=", times: totalChars)
        results.forEach {
            printer.printInfo(getResultOutputString($0, numberOfCharacters: maximalPathChars))
        }
        print("=", times: totalChars)
        printStatisticsString()
    }
    
    private func getResultOutputString(resultOutput: ResultOutput, numberOfCharacters charNum: Int) -> String {
        let missingSpacesString = " " * (charNum - resultOutput.path.characters.count)
        let warningsString = "|".stringByAppendingString(getResultsString(resultOutput.warnings) + " |")
        return warningsString + resultOutput.path + missingSpacesString + "|"
    }
    
    private func printStatisticsString() {
        printer.printInfo("Found \(results.reduce(0) { $0 + $1.warnings }) violations in \(results.count) files.")
    }
    
    private func print(string: String, times: Int) {
        printer.printInfo(string * times)
    }
    
    private func getResultsString(warnings: Int) -> String {
        let checkmark = "\u{001B}[0;32m✓\u{001B}[0m"
        let warning = "⚠️"
        let explosion = "\u{1F4A5}"
        
        if warnings == 0 { return "  \(checkmark) " }
        else if warnings < 10 { return " \(warnings)" + warning + " " }
        else if warnings < 100 { return " \(warnings)" + warning }
        else { return "  \(explosion) " }
    }
}

extension Array where Element: StringType {
    var maxLength: Int {
        return self.reduce(0) { max($0, String($1).characters.count) }
    }
}
