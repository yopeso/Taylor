//
//  OptionsValidator.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/10/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//


struct OptionsValidator {
    
    func validateForSingleOptions(_ options: [Option]) -> Bool {
        do {
            try checkIfSingleOptionsAreRepeated(options)
        } catch CommandLineError.abuseOfOptions(let errorMsg) {
            errorPrinter.printError(errorMsg)
            return false
        } catch { return false }
        return true
    }
    
    
    fileprivate func checkIfSingleOptionsAreRepeated(_ options: [Option]) throws {
        _ = try [PathOption().name, TypeOption().name, ExcludesFileOption().name, VerbosityOption().name].map {
            if optionRepeatsInOptions(options, optionType: $0) > 1 {
                throw CommandLineError.abuseOfOptions("\nUnique options was indicated multiple times")
            }
        }
    }
    
    
    fileprivate func optionRepeatsInOptions(_ options: [Option], optionType: String) -> Int {
        return options.filter { $0.name == optionType }.count
    }
    
    
    func validateInformationalOptions(_ options: [InformationalOption]) throws {
        if options.isEmpty { return }
        var repeats = CustomizationRule()
        for option in options {
            let optionComponents = option.optionArgument.components(separatedBy: option.argumentSeparator)
            let optionType = optionComponents[0]
            do {
                try option.validateArgumentComponents(optionComponents)
            } catch CommandLineError.invalidInformationalOption(let errorMessage) {
                throw CommandLineError.invalidInformationalOption(errorMessage)
            } catch { }
            repeats.add(1, toKey: optionType)
            if repeats.values.max()! > 1 {
                throw CommandLineError.invalidInformationalOption("\n\(option.name) with \(optionType) type was declared multiple times.")
            }
        }
    }
    
}
