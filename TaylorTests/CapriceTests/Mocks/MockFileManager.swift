//
//  MockFileManager.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Cocoa
@testable import Caprice

class MockFileManager: NSFileManager {
    
    func testFile(fileName: String, fileType: String) -> String {
        let testBundle = NSBundle(forClass: self.dynamicType)
        return testBundle.pathForResource(fileName, ofType: fileType)!
    }
    
    
    override func fileExistsAtPath(path: String, isDirectory: UnsafeMutablePointer<ObjCBool>) -> Bool {
        switch path {
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
    
}
