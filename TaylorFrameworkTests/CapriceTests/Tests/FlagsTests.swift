//
//  FlagsTests.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/11/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class HelpFlagMock: HelpFlag {
    func executeTest() -> Bool {
        do {
            try printHelp("aa", "aa")
            return true
        } catch { return false }
    }
}

class FlagsTests: QuickSpec {
    override func spec() {
        describe("Flags") {
            
            var flagBuilder : FlagBuilder!
            
            beforeEach() {
                flagBuilder = FlagBuilder()
            }
            
            afterEach() {
                flagBuilder = nil
            }
            
            context("when being requested") {
                
                it("should return flag that corrensponds to given string") {
                    let returnedFlagName = flagBuilder.flag(HelpLong).name
                    let expectedFlagName = HelpFlag().name
                    expect(returnedFlagName).to(equal(expectedFlagName))
                }
                
                it("should return flag that corrensponds to given string") {
                    let returnedFlagName = flagBuilder.flag(VersionShort).name
                    let expectedFlagName = VersionFlag().name
                    expect(returnedFlagName).to(equal(expectedFlagName))
                }
                
                it("should return default help flag if given sring does not correnspond to any existing flag") {
                    let returnedFlagName = flagBuilder.flag("test").name
                    let expectedFlagName = HelpFlag().name
                    expect(returnedFlagName).to(equal(expectedFlagName))
                }
            }
            
            context("when being executed") {
                
                it("should not crash") {
                    flagBuilder.flag(HelpShort).execute()
                }
                
                it("should not crash") {
                    flagBuilder.flag(VersionLong).execute()
                }
                
            }
            
            context("when requesting help") {
                it("should throw error if help file is missing") {
                    expect(HelpFlagMock().executeTest()).to(beFalse())
                }
            }
            
        }
    }
}
