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
@testable import Taylor

class PacmanTests: QuickSpec {
    override func spec() {
        
        describe("generator") {
            it("should find number of WALL characters inside current map") {
                let testMap = WALL_CONST+WALL_CONST+WALL_CONST+" lafsdkj   "+WALL_CONST
                expect(Generator(map: testMap, paths: []).countWallCharacters()).to(equal(4))
            }
            
            context("when creating map") {
                it("should generate a string containing number of wall chars on map") {
                    let testMap = WALL_VAR+WALL_VAR+WALL_VAR+"\n"+WALL_VAR
                    expect(Generator(map: testMap, paths: []).generateMapString("23\n45")).to(equal("23 \n4"))
                }
            }
        }
    }
}



