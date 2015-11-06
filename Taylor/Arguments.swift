//
//  Arguments.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation
import Printer

class Arguments {
    let caprice = Caprice()
    let arguments: Options
    
    init () {
        arguments = caprice.processArguments(Process.arguments)
    }
    
    func finderParameters() -> Options {
        return arguments
    }
    
    func verbosityLevel() -> VerbosityLevel {
        return caprice.getVerbosityLevel()
    }
    
    func rootPath() -> String? {
        return arguments["path"]?[0]
    }
    
    func reporterRepresentations() -> [OutputReporter] {
        return caprice.getReporters()
    }
    
    func thresholds() -> CustomizationRule {
        return caprice.getRuleThresholds()
    }
}