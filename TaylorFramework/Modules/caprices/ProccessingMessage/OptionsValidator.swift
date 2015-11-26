//
//  OptionsValidator.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/10/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//


final class OptionsValidator {
    
    func validateForSingleOptions(options: [Option]) -> Bool {
        do {
            try checkIfSingleOptionsAreRepeated(options)
        } catch CommandLineError.AbuseOfOptions(let errorMsg){
            errorPrinter.printError(errorMsg)
            return false
        } catch { return false }
        return true
    }
    
    
    private func checkIfSingleOptionsAreRepeated(options: [Option]) throws {
        _ = try [PathOption().name, TypeOption().name, ExcludesFileOption().name, VerbosityOption().name].map {
            if optionRepeatsInOptions(options, optionType: $0) > 1 {
                throw CommandLineError.AbuseOfOptions("\nUnique options was indicated multiple times")
            }
        }
    }
    
    
    private func optionRepeatsInOptions(options:[Option], optionType:String) -> Int {
        return options.filter { $0.name == optionType }.count
    }
    
    
    func validateInformationalOptions(options: [InformationalOption]) throws {
        var repeats = CustomizationRule()
        for option in options {
            let optionComponents = option.optionArgument.componentsSeparatedByString(option.argumentSeparator)
            let optionType = optionComponents[0]
            do {
                try option.validateArgumentComponents(optionComponents)
            } catch CommandLineError.InvalidInformationalOption(let errorMessage) {
                throw CommandLineError.InvalidInformationalOption(errorMessage)
            } catch { }
            repeats.add(1, toKey: optionType)
            if repeats.values.maxElement() > 1 {
                throw CommandLineError.InvalidInformationalOption("\n\(option.name) with \(optionType) type was declared multiple times.")
            }
        }
    }
    
}
