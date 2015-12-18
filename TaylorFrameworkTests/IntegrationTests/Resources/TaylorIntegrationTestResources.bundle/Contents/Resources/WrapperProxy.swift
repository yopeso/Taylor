//
//  WrapperOutputGenerator.swift
//  Swetler
//
//  Created by Seremet Mihai on 10/26/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

public class WrapperProxy {
    
    public init() { }
    
    
    // MARK: Public interface
    
    
    public func getWrapperOutputWithParameters(parameters: Parameters, verbosity: OutputVerbosity) throws -> String {
        if parameters.projectPath == .NilParameter || parameters.filesPaths == .NilParameter {
            return try Wrapper(verbosity: verbosity, parameters: parameters).getOutput()
        }
        let output1 = try getWrapperOutputWithProjectPath(verbosity, parameters: parameters)
        let output2 = try getWrapperOutputWithSpecificFiles(verbosity, parameters: parameters)
    
        return output1 + output2
    }
    
    
    // MARK: Private methods
    
    
    private func getWrapperOutputWithProjectPath(verbosity: OutputVerbosity, var parameters: Parameters) throws -> String {
        parameters.filesPaths = .NilParameter
        
        return try Wrapper(verbosity: verbosity, parameters: parameters).getOutput()
    }
    
    
    private func getWrapperOutputWithSpecificFiles(verbosity: OutputVerbosity, var parameters: Parameters) throws -> String {
        let projectPath = parameters.projectPath.associated as! String
        parameters.projectPath = .NilParameter
        if parameters.settingsPath == .NilParameter {
            parameters.settingsPath = .StringParameter(projectPath.stringByAppendingPathComponent(styleSettingsFileName))
        }
        if parameters.excludesPath == .NilParameter {
            parameters.excludesPath = .StringParameter(projectPath.stringByAppendingPathComponent(excludesFileName))
        }
        
        return try Wrapper(verbosity: verbosity, parameters: parameters).getOutput()
    }
    
}