//
//  Arguments.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

struct Arguments {
    let caprice = Caprice()
    let arguments: Options
    
    init () throws {
        arguments = try caprice.processArguments(Process.arguments)
    }
    
    var finderParameters: Options {
        return arguments
    }
    
    var verbosityLevel: VerbosityLevel {
        return caprice.getVerbosityLevel()
    }
    
    var rootPath: String? {
        return arguments["path"]?.first
    }
    
    var reporterRepresentations: [OutputReporter] {
        return caprice.getReporters()
    }
    
    var thresholds: CustomizationRule {
        return caprice.getRuleThresholds()
    }
}