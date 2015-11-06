//
//  Arguments.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

public class Arguments {
    public let caprice = Caprice()
    public let arguments: Options
    
    public init () {
        arguments = caprice.processArguments(Process.arguments)
    }
    
    public func finderParameters() -> Options {
        return arguments
    }
    
    public func verbosityLevel() -> VerbosityLevel {
        return caprice.getVerbosityLevel()
    }
    
    public func rootPath() -> String? {
        return arguments["path"]?[0]
    }
    
    public func reporterRepresentations() -> [OutputReporter] {
        return caprice.getReporters()
    }
    
    public func thresholds() -> CustomizationRule {
        return caprice.getRuleThresholds()
    }
}