//
//  ExcludesTests.swift
//  Finder
//
//  Created by Simion Schiopu on 9/7/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Quick
import Nimble
@testable import Finder

class ExcludesTests: QuickSpec {
    override func spec() {
        describe("Excludes") {
            context("when init with empty array") {
                var excludes: Excludes!
                beforeEach {
                    excludes = Excludes(paths: [], rootPath: "")
                }
                afterEach {
                    excludes = nil
                }
                it("should set absolutePaths with empty array") {
                    expect(excludes.absolutePaths.count).to(equal(0))
                }
                it("should set relativePaths with empty array") {
                    expect(excludes.relativePaths.count).to(equal(0))
                }
            }
            context("when init with array of paths") {
                var excludes: Excludes!
                beforeEach {
                    excludes = Excludes(paths: ["/Home/Desktop/Finder/Finder/main.swift",
                        "/Home/Desktop/Finder/Finder/test/*", ".*TestDirectory.*", "Test2.*", ".*Test3"],
                        rootPath: "/Home/Desktop/Finder")
                }
                afterEach {
                    excludes = nil
                }
                it("should set absolutePaths with paths") {
                    expect(excludes.absolutePaths.count).to(equal(2))
                    expect(excludes.absolutePaths).to(contain("Finder/main.swift", "Finder/test"))
                }
                it("should set relativePaths with paths") {
                    expect(excludes.relativePaths.count).to(equal(1))
                    expect(excludes.relativePaths).to(contain("TestDirectory"))
                }
            }
        }
    }
}