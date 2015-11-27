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

final class RuleCustomizationOption: InformationalOption {
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var optionArgument : String
    let name = "RuleCustomizationOption"
    
    let argumentSeparator = "="
    
    required init(argument: String = "") {
        optionArgument = argument
    }
    
    func setRuleToDictionary(dictionary: CustomizationRule) -> CustomizationRule {
        var newDictionary = dictionary
        let ruleComponents = optionArgument.componentsSeparatedByString(argumentSeparator)
        if ruleComponents.count < 2 { return CustomizationRule() }
        let key = ruleComponents.first!
        let value = ruleComponents.second!
        newDictionary[key] = Int(value)
        
        return newDictionary
    }
    
    func validateArgumentComponents(components: [String]) throws {
        if components.isEmpty { return }
        if components.count != 2 {
            throw CommandLineError.InvalidInformationalOption("\nRule customization argument contains too many \"=\" symbols")
        }
        if ruleCustomizationTypeDoesNotMatchPosibleTypes(components.first!) {
            throw CommandLineError.InvalidInformationalOption("\nInvalid rule customization type was indicated")
        }
        guard let _ = Int(components.second!) else {
            throw CommandLineError.InvalidInformationalOption("\nValue for customization rule must be a number")
        }
    }
    
    private func ruleCustomizationTypeDoesNotMatchPosibleTypes(type:String) -> Bool {
        return ![ExcessiveClassLength, ExcessiveMethodLength, TooManyMethods,
            CyclomaticComplexity, NestedBlockDepth, NPathComplexity, ExcessiveParameterList].contains(type)
    }

}
