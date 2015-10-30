//
//  Parameters.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation
import Caprice
import Printer

class Parameters {
    let caprice = Caprice()
    let arguments: [String : [String]]
    
    init () {
        arguments = caprice.processArguments(Process.arguments)
    }
    
    func finderParameters() -> [String: [String]] {
        return arguments
    }
    
    func verbosityLevel() -> VerbosityLevel {
        return caprice.getVerbosityLevel()
    }
    
    func rootPath() -> String? {
        return arguments["path"]?[0]
    }
    
    func reporterRepresentations() -> [[String : String]] {
        return caprice.getReporters()
    }
    
    func thresholds() -> [String : Int] {
        return caprice.getRuleThresholds()
    }
}