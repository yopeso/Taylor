//
//  PacmanRunnerTests.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/11/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import TaylorFramework

class MockPacmanRunner: PacmanRunner {
    var play = false
    
    override func input() -> String { return (play) ? "Y" : "N" }
    
    override func runEasterEgg(paths: [Path]) { }
}

class PacmanRunnerTests: QuickSpec {
    
    override func spec() {
        
        describe("PacmanRunner") {
            
            var pacmanRunner : PacmanRunner!
            
            beforeEach {
                pacmanRunner = PacmanRunner()
            }
            
            afterEach {
                pacmanRunner = nil
            }
            
            it("should remove spaces and new lines from given string") {
                let initialString = "\n  \n string \n\n\t"
                expect(pacmanRunner.formatInputString(initialString)).to(equal("string"))
            }
            
            it("should not crash if user choose to play pacman") {
                let mockPacmanRunner = MockPacmanRunner()
                mockPacmanRunner.play = true
                mockPacmanRunner.runEasterEggPrompt()
            }
            
            it("should not crash if user choose to not play pacman") {
                let mockPacmanRunner = MockPacmanRunner()
                mockPacmanRunner.play = false
                mockPacmanRunner.runEasterEggPrompt()
            }
            
            it("should not crash when given empty array of paths") {
                let pacmanRunner = PacmanRunner()
                pacmanRunner.runEasterEgg([])
            }
            
        }
        
    }
}