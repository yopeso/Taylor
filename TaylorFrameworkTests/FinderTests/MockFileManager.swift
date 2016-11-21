//
//  FakeFileManager.swift
//  Finder
//
//  Created by Simion Schiopu on 8/28/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation
@testable import TaylorFramework

class MockFileManager: FileManager {
    
    override func subpathsOfDirectory(atPath path: String) throws -> [String] {
        if path == "/Home/Test2" {
            return []
        }
        if path != "/Home/Finder" {
            throw FinderError.wrongFilePath(path: path)
        }
        
        return ["Finder", "FinderTests", "Finder/Controllers",
            "Finder/main.swift", "FinderTests/FinderTests.swift",
            "FinderTests/Info.plist",
            "Finder/Controllers/MainViewController.swift",
            "Finder/Controllers/AccountViewController.swift",
            "Finder.xcodeproj", "Readme.md", ".git"]
    }
    
    override func fileExists(atPath path: String) ->Bool {
        var isDir = ObjCBool(false)
        
        return self.fileExists(atPath: path, isDirectory: &isDir)
    }
    
    override func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) ->Bool {
        switch path {
        case "/Home/Finder/Finder", "/Home/Finder/FinderTests",
            "/Home/Finder/Finder/Controllers", "/Home/Finder", "/Home/Test", "/Home/Test2":
            isDirectory?.pointee = true
            return true
        case "/Home/Finder/Finder/main.swift", "/Home/Finder/FinderTests/FinderTests.swift", "/Home/Finder/FinderTests/Info.plist",
            "/Home/Finder/Finder/Controllers/MainViewController.swift", "/Home/Finder/Finder/Controllers/AccountViewController.swift",
            "/Home/Finder/Finder.xcodeproj", "/Home/Finder/Readme.md", "/Home/Finder/.git":
            isDirectory?.pointee = false
            return true
        case "pathToFile.yml", "pathToFile.txt", testFile("excludes", fileType: "yml"), testFile("emptyExcludes", fileType: "yml"):
            isDirectory?.pointee = false
            return true
        default:
            return false
        }
    }
    
    func testFile(_ fileName: String, fileType: String) -> String {
        let testBundle = Bundle(for: type(of: self))
        return testBundle.path(forResource: fileName, ofType: fileType)!
    }
}
