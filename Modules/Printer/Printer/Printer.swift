//
//  Printer.swift
//  Printer
//
//  Created by Andrei Raifura on 9/10/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

public enum VerbosityLevel {
    case Info, Warning, Error
}


public protocol Printing {
    func printMessage(text: String)
}


struct DefaultReporter : Printing {
    func printMessage(text: String) {
        print(text)
    }
}


public class Printer {
    private let reporter: Printing
    let verbosity: VerbosityLevel
    
    public init(verbosityLevel: VerbosityLevel, reporter: Printing = DefaultReporter()) {
        verbosity = verbosityLevel
        self.reporter = reporter
    }
    
    public func printInfo(text: String) {
        if verbosity == .Info {
            reporter.printMessage(text)
        }
    }
    
    public func printWarning(text: String) {
        if [.Warning, .Info].contains(verbosity) {
            reporter.printMessage(text)
        }
    }
    
    public func printError(text: String) {
        reporter.printMessage(text)
    }
}
