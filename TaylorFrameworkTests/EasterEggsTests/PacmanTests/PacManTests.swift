//
//  FileContentTests.swift
//  Scissors
//
//  Created by Alexandru Culeva on 9/3/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import TaylorFramework

class PacmanTests: QuickSpec {
    override func spec() {
        
        describe("generator") {
            it("should find number of WALL characters inside current map") {
                let testMap = "\(WALL_CONST)\(WALL_CONST)\(WALL_CONST)lafsdkj   \(WALL_CONST)"
                expect(Generator(map: testMap, paths: []).countWallCharacters()).to(equal(4))
            }
            
            context("when creating map") {
                it("should generate a string containing number of wall chars on map") {
                    let testMap = "\(WALL_VAR)\(WALL_VAR)\(WALL_VAR)\n\(WALL_VAR)"
                    expect(Generator(map: testMap, paths: []).generateMapString("23\n45")).to(equal("23 \n4"))
                }
                it("should return string if provided a real path") {
                    let testMap = "\(WALL_CONST)\(WALL_CONST)\(WALL_CONST)\(WALL_CONST)"
                    expect(Generator(map: testMap, paths: [MockFileReader().pathForFile("TestFileMoreThan500", fileType: "swift")]).getText()).toNot(beEmpty())
                }
            }
        }
        
        let tempPath = "\(NSHomeDirectory())" + "/tmp"
        var pacman: Pacman!
        beforeEach() {
            pacman = Pacman(paths: [""])
        }
        
        describe("pacman") {
            context("when working with map file") {
                it("should create temporary subdirectory correctly") {
                    if FileManager.default.fileExists(atPath: tempPath) {
                        FileManager.default.removeFileAtPath(tempPath)
                    }
                    _ = pacman.createMap()
                    expect(FileManager.default.fileExists(atPath: tempPath)).to(beTrue())
                }
                it("should create it in the right place") {
                    _ = pacman.createMap()
                    expect(FileManager.default.fileExists(atPath: tempPath + "/map.dat")).to(beTrue())
                    pacman.removeMap()
                }
                it("should remove it if asked to") {
                    _ = pacman.createMap()
                    pacman.removeMap()
                    expect(FileManager.default.fileExists(atPath: tempPath + "/map.dat")).to(beFalse())
                }
                it("should recreate it if already exists") {
                    _ = pacman.createMap()
                    _ = pacman.createMap()
                    expect(FileManager.default.fileExists(atPath: tempPath + "/map.dat")).to(beTrue())
                    pacman.removeMap()
                }
            }
            
            context("when initialized") {
                it("should early return if array is empty") {
                    let pacman = Pacman(paths: [])
                    pacman.start()
                    expect(FileManager.default.fileExists(atPath: tempPath)).to(beFalse())
                }
            }
        }
    }
}



