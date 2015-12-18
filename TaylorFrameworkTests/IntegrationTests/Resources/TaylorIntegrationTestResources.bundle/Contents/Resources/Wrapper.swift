//
//  Wrapper.swift
//  swetler
//
//  Created by Seremet Mihai on 10/9/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

public enum OutputVerbosity {
    case StandardOutput
    case StandardError
}

public final class Wrapper {
    
    private let resourceName = "Objective-Clean"
    private let resourceExtenstion = "app"
    public  var arguments : [String] = []
    public  var outputVerbosity : OutputVerbosity
    private var runTask = NSTask()
    private let pipe = NSPipe()
    public static  var itemsPathsToDelete = [String]()
    public static  var originalPaths = [String : String]()
    public static  var analyzePaths = [String]()

    
    // MARK: Initialization
    
    
    public  init(verbosity: OutputVerbosity) {
        self.outputVerbosity = verbosity
    }
    
    convenience public init(verbosity: OutputVerbosity, parameters: Parameters) throws {
        self.init(verbosity: verbosity)
        if let path = parameters.projectPath.associated as? String {
            arguments.append(path)
            do {
                try copyResourceFilesIfNedeed(parameters, toPath: path)
            } catch let error {
                print(error)
            }
        } else if let files = parameters.filesPaths.associated as? [String] {
            guard let settings = parameters.settingsPath.associated as? String else {
                throw MissingResourcesError.StyleSettingsMissingError(message: "Missing style settings file path.")
            }
            guard let excludes = parameters.excludesPath.associated as? String else {
                throw MissingResourcesError.ExcludeFileMissingError(message: "Missing exclude file path.")
            }
            arguments.append(createWrapperEnviroment(filesToCheck: files, settingsFilePath: settings, excludeFilePath: excludes))
            Wrapper.itemsPathsToDelete.append(arguments.last!)
        }
        if let path = arguments.last {
            Wrapper.analyzePaths.append(path)
        }
    }
    
    
    // MARK: Public interface
    
    
    public func getOutput() throws -> String {
        configureRunTask()
        try run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        
        return output
    }
    
    
    // MARK: Private methods
    
    
    private func configureRunTask() {
        runTask.launchPath = findObjectiveCleanAppPath()
        if outputVerbosity == .StandardOutput {
            runTask.standardOutput = pipe
        } else {
            runTask.standardError = pipe
        }
    }
    
    
    private func run() throws {
        deleteAppCaches()
        runTask.arguments = arguments
        runTask.launch()
        executeAppleScript()
    }
    
    
    private func findObjectiveCleanAppPath() -> String? {
        let bundle = NSBundle(forClass: self.dynamicType)
        if let path = bundle.pathForResource(resourceName, ofType: resourceExtenstion) {
            return path.stringByAppendingPathComponent("/Contents/Resources/ObjClean.app/Contents/MacOS/ObjClean")
        }
        
        return nil
    }
    
    
    private func deleteAppCaches() {
        let objCleanCachePaths = ["/Users/" + NSUserName() + "/Library/Caches/com.objClean", "/Users/" + NSUserName() + "/Library/Caches/com.objClean.Enforcer"]
        let fileManager = NSFileManager.defaultManager()
        do {
            let _ = try objCleanCachePaths.filter({ fileManager.fileExistsAtPath($0) }).map {
                let _ = try fileManager.listOfFilesAtPath($0).map {
                    fileManager.removeFileAtPath($0)
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    
    private func executeAppleScript() {
        let operationQueue = NSOperationQueue()
        operationQueue.addOperation(CloseDialogWindowOperation())
    }
    
    
    // MARK: Resources fils manipulation
    
    private func copyResourceFilesIfNedeed(parameters: Parameters, toPath path: String) throws {
        try copyExcludeFile(parameters, toPath: path)
        try copySettingsFile(parameters, toPath: path)
    }
    
    
    private func copyExcludeFile(parameters: Parameters, toPath: String) throws {
        if let excludes = parameters.excludesPath.associated as? String {
            if toPath.stringByAppendingPathComponent(excludesFileName) == excludes {
                return
            }
            try copyItemsAtPaths([excludes], toPath: toPath)
            Wrapper.itemsPathsToDelete.append(toPath.stringByAppendingPathComponent(excludes.lastPathComponent))
        }
    }
    
    
    private func copySettingsFile(parameters: Parameters, toPath: String) throws {
        if let settings = parameters.settingsPath.associated as? String {
            if toPath.stringByAppendingPathComponent(styleSettingsFileName) == settings {
                return
            }
            try copyItemsAtPaths([settings], toPath: toPath)
            Wrapper.itemsPathsToDelete.append(toPath.stringByAppendingPathComponent(settings.lastPathComponent))
        }
    }
    
    
    private func createWrapperEnviroment(filesToCheck filePaths: [String], settingsFilePath settingsPath: String, excludeFilePath excludePath: String) -> String {
        let resourcesDirectoryName = "." + String.randomStringWithLength(10)
        let resourcesPath = NSFileManager.defaultManager().currentDirectoryPath.stringByAppendingPathComponent(resourcesDirectoryName)
        let filesPath = resourcesPath.stringByAppendingPathComponent("Files")
        do {
            try createDirectoryAtPath(resourcesPath)
            try createDirectoryAtPath(filesPath)
            try copyItemsAtPaths([settingsPath, excludePath], toPath: resourcesPath)
            try copyItemsAtPaths(filePaths, toPath: filesPath)
        } catch let error {
            print(error)
        }
        
        return resourcesPath
    }
    
    
    private func copyItemsAtPaths(paths: [String], toPath: String) throws {
        let _ = try paths.map() {
            try NSFileManager.defaultManager().copyOrReplaceFileAtPath($0, toPath: toPath.stringByAppendingPathComponent($0.lastPathComponent))
            Wrapper.originalPaths.updateValue(toPath.stringByAppendingPathComponent($0.lastPathComponent), forKey: $0)
        }
    }
    
    
    private func createDirectoryAtPath(path: String) throws {
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
}


