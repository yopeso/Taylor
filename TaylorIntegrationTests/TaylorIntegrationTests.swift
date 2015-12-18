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

enum IntegrationTestsError: ErrorType {
    case FileNotFount(String)
    case BundleResourceNotFount(String)
}

class TaylorIntegrationTests: QuickSpec {
    
    var runTaskPath : String {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let bundlePath = testBundle.bundlePath
        return bundlePath.stringWithoutLastComponent().stringByAppendingPathComponent("Taylor.app/Contents/MacOS/Taylor")
    }
    
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
    
    
    func initializePaths() throws {
        let mainBundle = NSBundle(forClass: self.dynamicType)
        if let resourcesPath = mainBundle.resourcePath {
            analyzeFilesPath = resourcesPath.stringByAppendingPathComponent("AnalyzeFiles")
            resultFilePath = resourcesPath.stringByAppendingPathComponent("Result")
        } else {
            throw IntegrationTestsError.BundleResourceNotFount(mainBundle.bundlePath)
        }
    }
    
    
    func createResources() throws {
        let mainBundle = NSBundle(forClass: self.dynamicType)
        if let path = mainBundle.pathForResource("TaylorIntegrationTestResources", ofType: "bundle"), let bundle = NSBundle(path: path) {
            if !NSFileManager.defaultManager().fileExistsAtPath(analyzeFilesPath) {
                try NSFileManager.defaultManager().createDirectoryAtPath(analyzeFilesPath, withIntermediateDirectories: false, attributes: nil)
            }
            if !NSFileManager.defaultManager().fileExistsAtPath(resultFilePath) {
                try NSFileManager.defaultManager().createDirectoryAtPath(resultFilePath, withIntermediateDirectories: false, attributes: nil)
            }
            try createFiles(bundle)
            try createResultFile(bundle)
        } else {
            throw IntegrationTestsError.BundleResourceNotFount("TaylorIntegrationTestResources")
        }
    }
    
    
    private func createFiles(sourceBundle: NSBundle) throws {
        for fileName in fileNames {
            if let path = sourceBundle.pathForResource(fileName.stringByTrimmingTheExtension, ofType: fileName.fileExtension) {
                try NSFileManager.defaultManager().copyItemAtPath(path, toPath: self.analyzeFilesPath.stringByAppendingPathComponent(path.lastPathComponent))
            } else {
                throw IntegrationTestsError.BundleResourceNotFount("fileName")
            }
        }
    }
    
    
    private func createResultFile(sourceBundle: NSBundle) throws {
        if let path = sourceBundle.pathForResource(resultFileName.stringByTrimmingTheExtension, ofType: resultFileName.fileExtension) {
            resultFilePath = resultFilePath.stringByAppendingPathComponent(resultFileName)
            try NSFileManager.defaultManager().copyItemAtPath(path, toPath: self.resultFilePath)
        } else {
            throw IntegrationTestsError.BundleResourceNotFount(resultFileName)
        }
    }
    
    
    override func spec() {
        
//        do {
//            try self.initializePaths()
//        } catch let error {
//            print(error)
//        }
//        
//        describe("Taylor") {
//            
//            beforeEach {
//                do {
//                    try self.createResources()
//                } catch let error {
//                    print(error)
//                }
//            }
//            
//            
//            afterEach {
//                do {
//                    try self.cleanOrDestroyResources()
//                } catch let error {
//                    print(error)
//                }
//            }
//            
//            it("should generate correct reports") {
//                let runTask = NSTask()
//                runTask.launchPath = self.runTaskPath
//                runTask.arguments = ["-p", self.analyzeFilesPath, "-r", "json:taylor_report.json"]
//                runTask.launch()
//                runTask.waitUntilExit()
//                let reporterPath = self.analyzeFilesPath.stringByAppendingPathComponent("taylor_report.json")
//                expect(ReporterComparator().compareReporters(self.resultFilePath, secondReporterPath: reporterPath)).to(beTrue())
//                do {
//                    if NSFileManager.defaultManager().fileExistsAtPath(reporterPath) {
//                        try NSFileManager.defaultManager().removeItemAtPath(reporterPath)
//                    }
//                } catch let error {
//                    print(error)
//                }
//            }
//            
//        }
        
    }
    
}
