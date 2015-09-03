//
//  FileContentTests.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import BoundariesKit

class FileContentTests: QuickSpec {
    override func spec() {
        
        describe("File Content") {
            
            let path = "path/to/tests"
            let content = FileContent(path: path, components: [])

            it("should contain path and components") {
                expect(content.path).to(equal(path))
                expect(content.components).to(equal([]))
            }
            
            it("should be equal to a identical file content") {
                let identicalContent = FileContent(path: path, components: [])
                expect(content).to(equal(identicalContent))
            }
            
            it("should not be equal to a different file content") {
                let differentContent = FileContent(path: "different/path", components: [])
                expect(content).notTo(equal(differentContent))
            }
        }
    }
    
}
