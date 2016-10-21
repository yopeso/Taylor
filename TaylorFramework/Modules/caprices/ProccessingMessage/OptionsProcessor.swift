//
//  OptionsProcessor.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/7/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Cocoa
import ExcludesFileReader

private let EmptyResultDictionary = Options()

private let optionReporterType: [String: Option.Type] = [
    PathLong: PathOption.self, PathShort: PathOption.self,
    TypeLong: TypeOption.self, TypeShort: TypeOption.self,
    FileLong: FileOption.self, FileShort: FileOption.self,
    ExcludeLong: ExcludeOption.self, ExcludeShort: ExcludeOption.self,
    ExcludesFileLong: ExcludesFileOption.self, ExcludesFileShort: ExcludesFileOption.self,
    ReporterLong: ReporterOption.self, ReporterShort: ReporterOption.self,
    RuleCustomizationLong: RuleCustomizationOption.self,
    RuleCustomizationShort: RuleCustomizationOption.self,
    VerbosityLong: VerbosityOption.self, VerbosityShort: VerbosityOption.self
]

/*
If you change this class don't forget to fix his mock for actual right tests (if is case)
*/
class OptionsProcessor {
    
    var analyzePath = FileManager.default.currentDirectoryPath
    var isExcludesFileIndicated = false
    let optionsValidator = OptionsValidator()
    var factory = InformationalOptionsFactory()
    var infoOptions = [InformationalOption]()
    var executableOptions = [ExecutableOption]()
    
    func processOptions(arguments: [String]) throws -> Options {
        let options = try processArguments(arguments)
        guard !options.isEmpty && OptionsValidator().validateForSingleOptions(options) else { return EmptyResultDictionary }
        analyzePath = options.filter { $0 is PathOption }.first?.optionArgument.absolutePath() ?? analyzePath
        let resultDictionary = buildResultDictionaryFromOptions(executableOptions)
        guard processInformationalOptions() else { return EmptyResultDictionary }
        factory = InformationalOptionsFactory(infoOptions: infoOptions)
        return resultDictionary
    }
    
    func processArguments(_ arguments: [String]) throws -> [Option] {
         return try arguments.dropFirst().reduceTwoElements([]) {
            guard let optionObject = optionObjectFromOption($1, argument: $2) else {
                throw CommandLineError.invalidArguments("Error committed on option `\($1)`.")
            }
            return $0 + optionObject
        }
    }
    
    func processInformationalOptions() -> Bool {
        do {
            try optionsValidator.validateInformationalOptions(infoOptions)
        } catch CommandLineError.invalidInformationalOption(let errorMsg) {
            errorPrinter.printError(errorMsg)
            return false
        } catch { return false }
        
        return true
    }
    
    private func buildResultDictionaryFromOptions(_ options: [ExecutableOption]) -> Options {
        var resultDictionary = EmptyResultDictionary
        if executeOptionsOnDictionary(&resultDictionary, options: options) {
            setDefaultValuesToResultDictionary(&resultDictionary)
        }
        
        return resultDictionary
    }
    
    func setDefaultValuesToResultDictionary(_ dictionary: inout Options) {
        setDefaultPathAndTypeToDictionary(&dictionary)
        if !isExcludesFileIndicated { setDefaultExcludesToDictionary(&dictionary) }
    }
    
    private func setDefaultPathAndTypeToDictionary(_ dictionary: inout Options) {
        let defaultDictionary = MessageProcessor().defaultDictionaryWithPathAndType()
        dictionary.setIfNotExist(defaultDictionary[ResultDictionaryPathKey] ?? [], forKey: ResultDictionaryPathKey)
        dictionary.setIfNotExist(defaultDictionary[ResultDictionaryTypeKey] ?? [], forKey: ResultDictionaryTypeKey)
    }
    
    
    private func setDefaultExcludesToDictionary(_ dictionary: inout Options) {
        guard let pathKey = dictionary[ResultDictionaryPathKey] , !pathKey.isEmpty else {
            return
        }
        var excludePaths = [String]()
        do {
            let excludesFilePath = MessageProcessor().defaultExcludesFilePathForDictionary(dictionary)
            excludePaths = try ExcludesFileReader().absolutePathsFromExcludesFile(excludesFilePath, forAnalyzePath:pathKey.first!)
        } catch {
            return
        }
        addExcludePathsToDictionary(&dictionary, excludePaths: excludePaths)
    }
    
    
    private func addExcludePathsToDictionary(_ dictionary: inout Options, excludePaths: [String]) {
        if excludePaths.isEmpty { return }
        dictionary.add(excludePaths, toKey: ResultDictionaryExcludesKey)
    }
    
    
    private func executeOptionsOnDictionary(_ dictionary: inout
        
        Options, options: [ExecutableOption]) -> Bool {
        for var option in options {
            option.analyzePath = analyzePath
            option.executeOnDictionary(&dictionary)
            if dictionary[ResultDictionaryErrorKey] != nil {
                dictionary = EmptyResultDictionary
                errorPrinter.printError("Error committed on option `\(option.name)` " +
                    "with argument \(option.optionArgument).")
                return false
            }
        }
        
        return true
    }
    
    private func optionObjectFromOption(_ option: String, argument: String) -> Option? {
        if option == ExcludesFileLong || option == ExcludesFileShort { isExcludesFileIndicated = true }
        if let optionType = optionReporterType[option] {
            return configureOption(optionType, argument: argument)
        }
        return nil
    }
    
}

extension OptionsProcessor {
    func configureOption(_ optionType: Option.Type, argument: String) -> Option {
        let option = optionType.init(argument: argument)
        if let infoOption = option as? InformationalOption {
            infoOptions.append(infoOption)
        } else {
            executableOptions.append(option as! ExecutableOption) // Safe to force unwrap
        }
        
        return option
    }
}

extension Sequence {
    func reduceTwoElements<T>(_ initial: T, combine: (T, Iterator.Element, Iterator.Element) throws -> T) rethrows -> T {
        var result = initial
        for (first, second) in zip(enumerated().filter { $0.0.isEven }.map { $0.1 },
                                   enumerated().filter {$0.0.isOdd }.map {$0.1}) {
                                    result = try combine(result, first, second)
        }
        return result
    }
}
