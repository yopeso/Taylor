//
//  OptionsProcessor.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/7/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Cocoa

private let EmptyResultDictionary = Options()

/*
If you change this class don't forget to fix his mock for actual right tests (if is case)
*/
class OptionsProcessor {
    
    var analyzePath = NSFileManager.defaultManager().currentDirectoryPath
    var isExcludesFileIndicated = Bool(false)
    let optionsValidator = OptionsValidator()
    var factory = InformationalOptionsFactory()
    var infoOptions = [InformationalOption]()
    var executableOptions = [ExecutableOption]()
    
    func processOptions(arguments: [String]) -> Options {
        let options = optionsFromArguments(arguments)
        if options.isEmpty {
            errorPrinter.printError("\nInvalid option was indicated")
            return EmptyResultDictionary
        }
        analyzePath = currentAnalyzedPath(options)
        if !OptionsValidator().validateForSingleOptions(options) { return EmptyResultDictionary }
        let resultDictionary = buildResultDictionaryFromOptions(executableOptions)
        guard processInformationalOptions() else { return EmptyResultDictionary }
        factory = InformationalOptionsFactory(infoOptions: infoOptions)
        return resultDictionary
    }
    
    func processInformationalOptions() -> Bool {
        do {
            try optionsValidator.validateInformationalOptions(infoOptions)
        } catch CommandLineError.InvalidInformationalOption(let errorMsg) {
            errorPrinter.printError(errorMsg)
            return false
        } catch { return false }
        
        return true
    }
    
    func currentAnalyzedPath(options:[Option]) -> String {
        return options.filter{ $0 is PathOption }.first?.optionArgument.absolutePath() ?? analyzePath
    }
    
    
    private func buildResultDictionaryFromOptions(options: [ExecutableOption]) -> Options {
        var resultDictionary = EmptyResultDictionary
        if executeOptionsOnDictionary(&resultDictionary, options: options) {
            setDefaultValuesToResultDictionary(&resultDictionary)
        }
        
        return resultDictionary
    }
    
    
    func setDefaultValuesToResultDictionary(inout dictionary: Options) {
        setDefaultPathAndTypeToDictionary(&dictionary)
        if !isExcludesFileIndicated { setDefaultExcludesToDictionary(&dictionary) }
    }
    
    
    private func setDefaultPathAndTypeToDictionary(inout dictionary: Options) {
        let defaultDictionary = MessageProcessor().defaultDictionaryWithPathAndType()
        dictionary.setIfNotExist(defaultDictionary[ResultDictionaryPathKey] ?? [], forKey: ResultDictionaryPathKey)
        dictionary.setIfNotExist(defaultDictionary[ResultDictionaryTypeKey] ?? [], forKey: ResultDictionaryTypeKey)
    }
    
    
    private func setDefaultExcludesToDictionary(inout dictionary: Options) {
        guard let pathKey = dictionary[ResultDictionaryPathKey] where !pathKey.isEmpty else {
            return
        }
        var excludePaths = [String]()
        do {
            let excludesFilePath = MessageProcessor().defaultExcludesFilePathForDictionary(dictionary)
            excludePaths = try ExcludesFileReader().absolutePathsFromExcludesFile(excludesFilePath,  forAnalyzePath:dictionary[ResultDictionaryPathKey]!.first!)
        } catch {
            return
        }
        addExcludePathsToDictionary(&dictionary, excludePaths: excludePaths)
    }
    
    
    private func addExcludePathsToDictionary(inout dictionary: Options, excludePaths:[String]) {
        if excludePaths.isEmpty { return }
        dictionary.add(excludePaths, toKey: ResultDictionaryExcludesKey)
    }
    
    
    private func executeOptionsOnDictionary(inout dictionary: Options, options:[ExecutableOption]) -> Bool {
        for var option in options {
            option.analyzePath = analyzePath
            option.executeOnDictionary(&dictionary)
            if dictionary[ResultDictionaryErrorKey] != nil {
                dictionary = EmptyResultDictionary
                return false
            }
        }
        
        return true
    }
    
    
    private func optionsFromArguments(arguments: [String]) -> [Option] {
        var options = [Option]()
        for var index = 1; index < arguments.count; index+=2 {
            let option = arguments[index]
            let optionArgument = arguments[index + 1]
            let optionObject = optionObjectFromOption(option, argument: optionArgument)
            if optionObject == nil { return [] }
            options.append(optionObject!)
        }
        
        return options
    }
    
    
    private func optionObjectFromOption(option:String, argument:String) -> Option? {
        switch option {
        case PathLong, PathShort:
            return configureOption(PathOption.self, argument: argument)
        case TypeLong, TypeShort:
            return configureOption(TypeOption.self, argument: argument)
        case FileLong, FileShort:
            return configureOption(FileOption.self, argument: argument)
        case ExcludeLong, ExcludeShort:
            return configureOption(ExcludeOption.self, argument: argument)
        case ExcludesFileLong, ExcludesFileShort:
            isExcludesFileIndicated = true
            return configureOption(ExcludesFileOption.self, argument: argument)
        case ReporterLong, ReporterShort:
            return configureOption(ReporterOption.self, argument: argument)
        case RuleCustomizationLong, RuleCustomizationShort:
            return configureOption(RuleCustomizationOption.self, argument: argument)
        case VerbosityLong, VerbosityShort:
            return configureOption(VerbosityOption.self, argument: argument)
        default:
            return nil
        }
    }
    
    func configureOption<T: Option>(option: T.Type, argument: String) -> T {
        let option = T(argument: argument)
        if let infoOption = option as? InformationalOption { infoOptions.append(infoOption) }
        else { executableOptions.append(option as! ExecutableOption) } // Safe to force unwrap
        
        return option
    }
}
