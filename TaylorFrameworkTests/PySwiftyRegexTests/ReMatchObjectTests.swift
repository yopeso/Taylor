// ReMatchObjectTests.swift
// Copyright (c) 2015 Ce Zheng
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
@testable import TaylorFramework

class ReMatchObjectTests: XCTestCase {  
  func testExpand() {
    let regex = re.compile("(this).+(that)")
    let string = "this one is different from that one."
    let m = regex.match(string)
    XCTAssertNotNil(m)
    let match = m!
    XCTAssertEqual(match.string, string)
    XCTAssertEqual(match.expand("$2 ~ $1"), "that ~ this")
  }
  
  func testGroups() {
    let m = re.match("(\\d+)\\.(\\d+)", "24.1632")
    XCTAssertNotNil(m)
    let match = m!
    XCTAssertEqual(match.string, "24.1632")
    let groups = match.groups()
    XCTAssertFalse(groups.isEmpty)
    XCTAssertEqual(groups[0]!, "24")
    XCTAssertEqual(groups[1]!, "1632")
  }
  
  func testGroupsWithNoGroup() {
    let m = re.match("\\d+\\.\\d+", "24.1632")
    XCTAssertNotNil(m)
    let match = m!
    XCTAssertEqual(match.string, "24.1632")
    let groups = match.groups()
    XCTAssertTrue(groups.isEmpty)
  }
  
  func testGroupsWithDefault() {
    let m = re.match("(\\d+)\\.?(\\d+)?", "24")
    XCTAssertNotNil(m)
    let match = m!
    let groups = match.groups()
    XCTAssertEqual(groups[0]!, "24")
    XCTAssertNil(groups[1])
    XCTAssertEqual(match.groups("0"), ["24", "0"])
  }
}
