//
//  Printer.swift
//  Printer
//
//  Created by Andrei Raifura on 9/10/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

enum VerbosityLevel {
    case Info, Warning, Error
}


protocol Printing {
    func printMessage(text: String)
}


struct DefaultReporter : Printing {
    func printMessage(text: String) {
        print(text)
    }
}


struct Printer {
    
    private let reporter: Printing
    let verbosity: VerbosityLevel
    
    init(verbosityLevel: VerbosityLevel, reporter: Printing = DefaultReporter()) {
        verbosity = verbosityLevel
        self.reporter = reporter
    }
    
    func printInfo(text: String) {
        if verbosity == .Info {
            reporter.printMessage(text)
        }
    }
    
    func printWarning(text: String) {
        if [.Warning, .Info].contains(verbosity) {
            reporter.printMessage(text)
        }
    }
    
    func printError(text: String) {
        reporter.printMessage(text)
    }
}
