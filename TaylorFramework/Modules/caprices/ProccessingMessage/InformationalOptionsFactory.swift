//
//  InformationalOptionsFactory.swift
//  Caprices
//
//  Created by Alex Culeva on 11/2/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Cocoa
import Foundation

typealias OutputReporter = [String: String]
typealias CustomizationRule = [String: Int]

final class InformationalOptionsFactory {
    
    var infoOptions: [InformationalOption]
    var reporterTypes = [OutputReporter]()
    var customizationRules = CustomizationRule()
    var verbosityLevel = VerbosityLevel.Error
    
    convenience init() {
        self.init(infoOptions: [])
    }
    
    init(infoOptions: [InformationalOption]) {
        self.infoOptions = infoOptions
        reporterTypes = getReporters()
        customizationRules = getRuleCustomizations()
        verbosityLevel = getVerbosityLevel()
    }
    
    func filterClassesOfType(name: String) -> [InformationalOption] {
        return infoOptions.filter { $0.name == name }
    }
    
    func getReporters() -> [OutputReporter] {
        let reporterOptions = filterClassesOfType(ReporterOption().name).map {
            $0 as! ReporterOption
        }
        return reporterOptions.reduce([]) { $0 + [$1.dictionaryFromArgument()] }
    }
    
    func getRuleCustomizations() -> CustomizationRule {
        let ruleCustomizationOptions = filterClassesOfType(RuleCustomizationOption().name).map {
            $0 as! RuleCustomizationOption
        }
        return ruleCustomizationOptions.reduce(CustomizationRule()) { $1.setRuleToDictionary($0) }
    }
    
    func getVerbosityLevel() -> VerbosityLevel {
        let verbosityOptions = filterClassesOfType(VerbosityOption().name).map {
            $0 as! VerbosityOption
        }
        guard verbosityOptions.count == 1 else {
            return VerbosityLevel.Error
        }
        return verbosityOptions[0].verbosityLevelFromOption()
    }
}