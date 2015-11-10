//
//  PathFormatterTests.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/2/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class PathFormatterTests: QuickSpec {
    override func spec() {
        describe("PathFormatter") {
            let currentPath = NSFileManager.defaultManager().currentDirectoryPath
            
            it("should return absolutePath if it is indicated") {
                expect(currentPath.absolutePath()).to(equal(currentPath))
            }
            
            it("should return absolute path for relative path") {
                let relativePath = "someDir/someFile"
                expect(relativePath.absolutePath()).to(equal(currentPath + "/" + relativePath))
            }
            
            it("should return formatted path if using parent directory shortcut (..)") {
                let relativePath = "someDir1/someDir2/../someDir3/someFile"
                expect(relativePath.absolutePath()).to(equal(currentPath + "/someDir1/someDir3/someFile"))
            }
            
            it("should return formatted path if using current directory shortcut (.)") {
                let relativePath = "someDir1/someDir2/./someDir3/someFile"
                expect(relativePath.absolutePath()).to(equal(currentPath + "/someDir1/someDir2/someDir3/someFile"))
            }
            
            it("should return same argument if it have .* prefix and sufix") {
                let path = ".*somePath.*"
                expect(path.formattedExcludePath()).to(equal(path))
            }
            
            it("should return empty string if excludes path contains .* prefix or sufix") {
                let path = ".*somePath"
                let path1 = "somePath.*"
                expect(path.formattedExcludePath()).to(equal(""))
                expect(path1.formattedExcludePath()).to(equal(""))
            }
            
            it("should return path created from home directory + path if path has tilde prefix") {
                let path = "~/somePath"
                let editedPath = path.stringByReplacingOccurrencesOfString("~", withString: "")
                expect(path.absolutePath()).to(equal(NSHomeDirectory() + editedPath))
            }
            
            it("should append relative path to indicated analyze path") {
                let analyzePath = "/analyzePath"
                let relativePath = "relativePath"
                expect(relativePath.formattedExcludePath(analyzePath)).to(equal(analyzePath + "/" + relativePath))
            }
            
            it("should append relative path to default path if analyze path was not indicated") {
                let relativePath = "relativePath"
                expect(relativePath.formattedExcludePath()).to(equal(currentPath + "/" + relativePath))
            }
            
            it("should return last component from path") {
                let testPath = "/path/to/something"
                expect(testPath.lastComponentFromPath()).to(equal("something"))
            }
            
        }
    }
}
