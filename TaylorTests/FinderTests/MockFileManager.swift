//
//  FakeFileManager.swift
//  Finder
//
//  Created by Simion Schiopu on 8/28/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation
@testable import Taylor

class MockFileManager: NSFileManager {
    
    override func subpathsOfDirectoryAtPath(path: String) throws -> [String] {
        if path != "/Home/Finder" {
            throw FinderError.WrongFilePath(path: path)
        }
        
        return ["Finder", "FinderTests", "Finder/Controllers",
            "Finder/main.swift", "FinderTests/FinderTests.swift",
            "FinderTests/Info.plist",
            "Finder/Controllers/MainViewController.swift",
            "Finder/Controllers/AccountViewController.swift",
            "Finder.xcodeproj", "Readme.md", ".git"]
    }
    
    override func fileExistsAtPath(path: String) ->Bool {
        var isDir = ObjCBool(false)
        
        return self.fileExistsAtPath(path, isDirectory: &isDir)
    }
    
    override func fileExistsAtPath(path: String, isDirectory: UnsafeMutablePointer<ObjCBool>) ->Bool {
        switch path {
        case "/Home/Finder/Finder", "/Home/Finder/FinderTests",
            "/Home/Finder/Finder/Controllers", "/Home/Finder":
            isDirectory.memory = true
            return true
        case "/Home/Finder/Finder/main.swift", "/Home/Finder/FinderTests/FinderTests.swift", "/Home/Finder/FinderTests/Info.plist",
            "/Home/Finder/Finder/Controllers/MainViewController.swift", "/Home/Finder/Finder/Controllers/AccountViewController.swift",
            "/Home/Finder/Finder.xcodeproj", "/Home/Finder/Readme.md", "/Home/Finder/.git":
            isDirectory.memory = false
            return true
        case "pathToDirectory":
            isDirectory.memory = true
            return true
        case "pathToFile.yml", "pathToFile.txt", testFile("excludes", fileType: "yml"), testFile("emptyExcludes", fileType: "yml"):
            isDirectory.memory = false
            return true
        default:
            return false
        }
    }
    
    func testFile(fileName: String, fileType: String) -> String {
        let testBundle = NSBundle(forClass: self.dynamicType)
        return testBundle.pathForResource(fileName, ofType: fileType)!
    }
}