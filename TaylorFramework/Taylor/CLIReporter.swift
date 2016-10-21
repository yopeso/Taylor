//
//  ResultPrinter.swift
//  Taylor
//
//  Created by Alex Culeva on 11/10/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

typealias ResultOutput = (path: String, warnings: Int)

struct CLIReporter {
    let results: [ResultOutput]
    
    init(results: [ResultOutput]) {
        self.results = results
    }
    
    func getResultsString() -> String {
        guard results.count > 0 else { return "" }
        let numberOfExtraCharacters = 9
        let maximalPathChars = results.map { $0.path }.maxLength
        let totalChars = maximalPathChars + numberOfExtraCharacters
        
        return results.reduce(getBorderString(totalChars)) {
            $0 + getResultOutputString($1, numberOfCharacters: maximalPathChars) + "\n"
            } + getBorderString(totalChars) + getStatisticsString()
    }
    
    fileprivate func getBorderString(_ size: Int) -> String {
        return "=" * size + "\n"
    }
    
    fileprivate func getResultOutputString(_ resultOutput: ResultOutput, numberOfCharacters charNum: Int) -> String {
        let missingSpacesString = " " * (charNum - resultOutput.path.characters.count)
        let warningsString = "|" + (getResultsString(resultOutput.warnings) + " |")
        return warningsString + resultOutput.path + missingSpacesString + "|"
    }
    
    fileprivate func getStatisticsString() -> String {
        return "Found \(results.reduce(0) { $0 + $1.warnings }) violations in \(results.count) files."
    }
    
    fileprivate func getResultsString(_ warnings: Int) -> String {
        let checkmark = "\u{001B}[0;32m✓\u{001B}[0m"
        let warning = "⚠️"
        let explosion = "\u{1F4A5}"
        
        if warnings == 0 {
            return "  \(checkmark) "
        } else if warnings < 100 {
            let string = " \(warnings)" + warning
            return string.padding(toLength: 5, withPad: " ", startingAt: 0)
        } else {
            return "  \(explosion) "
        }
    }
}

extension Array where Element: StringType {
    var maxLength: Int {
        return self.reduce(0) { Swift.max($0, String(describing: $1).characters.count) }
    }
}
