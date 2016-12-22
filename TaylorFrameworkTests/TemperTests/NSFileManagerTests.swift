//
//  NSFileManagerTests.swift
//  Temper
//
//  Created by Seremet Mihai on 10/7/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import TaylorFramework

fileprivate final class MockFileManagerNotRemovable: FileManager {
    enum FileManagerError: Error {
        case notRemovable
    }
    
    override func removeItem(atPath path: String) throws {
        throw FileManagerError.notRemovable
    }
}

class NSFileManagerTests: QuickSpec {
    override func spec() {
        describe("NSFileManager") {
            it("should remove file at path") {
                let manager = FileManager.default
                let path = manager.currentDirectoryPath as NSString
                let filePath = path.appendingPathComponent("file.txt") as String
                let content = "ia ibu"
                do {
                    try content.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                } catch _ { }
                expect(manager.fileExists(atPath: filePath)).to(beTrue())
                manager.removeFileAtPath(filePath)
                expect(manager.fileExists(atPath: filePath)).to(beFalse())
            }
            
            it("shouldn't remove file at path if it's not removable") {
                let manager = MockFileManagerNotRemovable()
                let path = manager.currentDirectoryPath as NSString
                let filePath = path.appendingPathComponent("file.txt") as String
                manager.createFile(atPath: filePath, contents: nil, attributes: nil)
                expect(manager.fileExists(atPath: filePath)).to(beTrue())
                manager.removeFileAtPath(filePath)
                expect(manager.fileExists(atPath: filePath)).to(beTrue())
                FileManager.default.removeFileAtPath(filePath)
            }
            
            it("shouldn't remove directory at path") {
                let manager = FileManager.default
                expect(manager.fileExists(atPath: manager.currentDirectoryPath)).to(beTrue())
                if manager.fileExists(atPath: (manager.currentDirectoryPath as NSString).appendingPathComponent("blablabla")) {
                    do {
                        try manager.removeItem(atPath: (manager.currentDirectoryPath as NSString).appendingPathComponent("blablabla"))
                    } catch let error {
                        print(error)
                    }
                }
                expect(manager.fileExists(atPath: (manager.currentDirectoryPath as NSString).appendingPathComponent("blablabla"))).to(beFalse())
            }
        }
    }
}
