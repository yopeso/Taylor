//
//  TaylorIntegrationTest.swift
//  TaylorIntegrationTest
//
//  Created by Seremet Mihai on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
import TaylorFramework

class TaylorIntegrationTests: QuickSpec {
    
    let runTaskPath = NSProcessInfo.processInfo().environment["PWD"]! + "/Taylor.app/Contents/MacOS/Taylor"
    
    var analyzeFilesPath = String()
    var resultFilePath = String()
    
    let resultFileName = "taylor_report.json"
    let fileNames = ["Wrapper.swift", "WrapperProxy.swift", "CloseDialogWindowOperation.swift"]

    
    func cleanOrDestroyResources() throws {
        if NSFileManager.defaultManager().fileExistsAtPath(analyzeFilesPath) {
            try NSFileManager.defaultManager().removeItemAtPath(analyzeFilesPath)
        }
        if NSFileManager.defaultManager().fileExistsAtPath(resultFilePath.stringWithoutLastComponent()) {
            try NSFileManager.defaultManager().removeItemAtPath(resultFilePath.stringWithoutLastComponent())
        }
    }
    
    
    func initializePaths() {
        let mainBundle = NSBundle(forClass: self.dynamicType)
        analyzeFilesPath = mainBundle.resourcePath!.stringByAppendingPathComponent("AnalyzeFiles")
        resultFilePath = mainBundle.resourcePath!.stringByAppendingPathComponent("ResultFiles")
    }
    
    
    func createResources() throws {
        let fileManager = NSFileManager.defaultManager()
        let mainBundle = NSBundle(forClass: self.dynamicType)
        let bundle = NSBundle(path: mainBundle.pathForResource("TaylorIntegrationTestResources", ofType: "bundle")!)!
        if !fileManager.fileExistsAtPath(analyzeFilesPath) {
            try NSFileManager.defaultManager().createDirectoryAtPath(analyzeFilesPath, withIntermediateDirectories: false, attributes: nil)
        }
        if !fileManager.fileExistsAtPath(resultFilePath) {
            try NSFileManager.defaultManager().createDirectoryAtPath(resultFilePath, withIntermediateDirectories: false, attributes: nil)
        }
        try createFiles(bundle)
        try createResultFile(bundle)
    }
    
    
    private func createFiles(sourceBundle: NSBundle) throws {
        for fileName in fileNames {
            let path = sourceBundle.pathForResource(fileName.stringByTrimmingTheExtension, ofType: fileName.fileExtension)!
            let toPath = self.analyzeFilesPath.stringByAppendingPathComponent(path.lastPathComponent)
            if !NSFileManager.defaultManager().fileExistsAtPath(toPath) {
                try NSFileManager.defaultManager().copyItemAtPath(path, toPath: toPath)
            }
        }
    }
    
    
    private func createResultFile(sourceBundle: NSBundle) throws {
        let path = sourceBundle.pathForResource(resultFileName.stringByTrimmingTheExtension, ofType: resultFileName.fileExtension)!
        resultFilePath = resultFilePath.stringByAppendingPathComponent(resultFileName)
        try NSFileManager.defaultManager().copyItemAtPath(path, toPath: self.resultFilePath)
    }
    
    
    override func spec() {
        
        self.initializePaths()
        
        describe("Taylor") {
            
            beforeEach {
                do { try self.createResources() }
                catch let error { print(error) }
            }
            
            
            afterEach {
                do { try self.cleanOrDestroyResources() }
                catch let error { print(error) }
            }
            
            it("should generate correct reports") {
                let runTask = NSTask()
                runTask.launchPath = self.runTaskPath
                runTask.arguments = ["-p", self.analyzeFilesPath, "-r", "json:taylor_report.json"]
                runTask.launch()
                runTask.waitUntilExit()
                let reporterPath = self.analyzeFilesPath.stringByAppendingPathComponent("taylor_report.json")
                expect(ReporterComparator().compareReporters(self.resultFilePath, secondReporterPath: reporterPath)).to(beTrue())
                do {
                    if NSFileManager.defaultManager().fileExistsAtPath(reporterPath) {
                        try NSFileManager.defaultManager().removeItemAtPath(reporterPath)
                    }
                } catch let error { print(error) }
            }
            
        }
        
    }
    
}
