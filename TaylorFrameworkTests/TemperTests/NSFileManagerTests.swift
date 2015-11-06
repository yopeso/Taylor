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

class NSFileManagerTests: QuickSpec {
    override func spec() {
        describe("NSFileManager") {
            it("should remove file at path") {
                let manager = NSFileManager.defaultManager()
                let path = manager.currentDirectoryPath as NSString
                let filePath = path.stringByAppendingPathComponent("file.txt") as String
                let content = "ia ibu"
                do {
                    try content.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
                } catch _ { }
                expect(manager.fileExistsAtPath(filePath)).to(beTrue())
                manager.removeFileAtPath(filePath)
                expect(manager.fileExistsAtPath(filePath)).to(beFalse())
            }
            it("should't remove directory at path") {
                let manager = NSFileManager.defaultManager()
                expect(manager.fileExistsAtPath(manager.currentDirectoryPath)).to(beTrue())
                if manager.fileExistsAtPath((manager.currentDirectoryPath as NSString).stringByAppendingPathComponent("blablabla")) {
                    do {
                        try manager.removeItemAtPath((manager.currentDirectoryPath as NSString).stringByAppendingPathComponent("blablabla"))
                    } catch let error {
                        print(error)
                    }
                }
                expect(manager.fileExistsAtPath((manager.currentDirectoryPath as NSString).stringByAppendingPathComponent("blablabla"))).to(beFalse())
            }
        }
    }
}
