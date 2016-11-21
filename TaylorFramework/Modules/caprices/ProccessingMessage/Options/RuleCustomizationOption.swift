//
//  RuleCustomizationOption.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/10/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let RuleCustomizationLong = "--ruleCustomization"
let RuleCustomizationShort = "-rc"

let ExcessiveClassLength = "ExcessiveClassLength"
let ExcessiveMethodLength = "ExcessiveMethodLength"
let TooManyMethods = "TooManyMethods"
let CyclomaticComplexity = "CyclomaticComplexity"
let NestedBlockDepth = "NestedBlockDepth"
let NPathComplexity = "NPathComplexity"
let ExcessiveParameterList = "ExcessiveParameterList"

struct RuleCustomizationOption: InformationalOption {
    var analyzePath = FileManager.default.currentDirectoryPath
    var optionArgument: String
    let name = "RuleCustomizationOption"
    
    let argumentSeparator = "="
    
    init(argument: String = "") {
        optionArgument = argument
    }
    
    func setRuleToDictionary(_ dictionary: CustomizationRule) -> CustomizationRule {
        var newDictionary = dictionary
        let ruleComponents = optionArgument.components(separatedBy: argumentSeparator)
        if ruleComponents.count < 2 { return CustomizationRule() }
        let key = ruleComponents.first!
        let value = ruleComponents.second!
        newDictionary[key] = Int(value)
        
        return newDictionary
    }
    
    func validateArgumentComponents(_ components: [String]) throws {
        if components.isEmpty { return }
        if components.count != 2 {
            throw CommandLineError.invalidInformationalOption("\nRule customization argument contains too many \"=\" symbols")
        }
        if ruleCustomizationTypeDoesNotMatchPosibleTypes(components.first!) {
            throw CommandLineError.invalidInformationalOption("\nInvalid rule customization type was indicated")
        }
        guard let _ = Int(components.second!) else {
            throw CommandLineError.invalidInformationalOption("\nValue for customization rule must be a number")
        }
    }
    
    fileprivate func ruleCustomizationTypeDoesNotMatchPosibleTypes(_ type: String) -> Bool {
        return ![ExcessiveClassLength, ExcessiveMethodLength, TooManyMethods,
            CyclomaticComplexity, NestedBlockDepth, NPathComplexity, ExcessiveParameterList].contains(type)
    }

}
