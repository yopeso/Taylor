//
//  Printer.swift
//  Printer
//
//  Created by Andrei Raifura on 9/10/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

enum VerbosityLevel {
    case info, warning, error
}


protocol Printing {
    func printMessage(_ text: String)
}


struct DefaultReporter: Printing {
    func printMessage(_ text: String) {
        print(text)
    }
}


struct Printer {
    
    fileprivate let reporter: Printing
    let verbosity: VerbosityLevel
    
    init(verbosityLevel: VerbosityLevel, reporter: Printing = DefaultReporter()) {
        verbosity = verbosityLevel
        self.reporter = reporter
    }
    
    func printInfo(_ text: String) {
        if verbosity == .info {
            reporter.printMessage(text)
        }
    }
    
    func printWarning(_ text: String) {
        if [.warning, .info].contains(verbosity) {
            reporter.printMessage(text)
        }
    }
    
    func printError(_ text: String) {
        reporter.printMessage(text)
    }
}
