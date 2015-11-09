// ReRegexObjectTests.swift
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

infix operator == {}

func == (left: [String?], right: [String?]) -> Bool {
  guard left.count == right.count else {
    return false
  }
  for (index, item) in left.enumerate() {
    if item != right[index] {
      return false
    }
  }
  return true
}

class ReRegexObjectTests: XCTestCase {
  func testMatchSuccess() {
    let regex = re.compile("(this).+(that)")
    let string = "this one is different from that one."
    let m = regex.match(string)
    XCTAssertNotNil(m)
    let match = m!
    XCTAssertEqual(match.string, string)
    XCTAssertEqual(match.group()!, "this one is different from that")
    XCTAssertEqual(match.group(1)!, "this")
    XCTAssertEqual(match.group(2)!, "that")
    XCTAssertEqual(match.span()!, string.startIndex..<string.startIndex.advancedBy(31))
    XCTAssertEqual(match.span(1)!, string.startIndex..<string.startIndex.advancedBy(4))
    XCTAssertEqual(match.span(2)!, string.startIndex.advancedBy(27)..<string.startIndex.advancedBy(31))
  }
  
  func testMatchWithRangeSuccess() {
    let regex = re.compile("(this).+(that).*")
    let string = "omg this one is different from that one."
    let m = regex.match(string, 4, 38)
    XCTAssertNotNil(m)
    let match = m!
    XCTAssertEqual(match.string, string)
    XCTAssertEqual(match.group()!, "this one is different from that on")
    XCTAssertEqual(match.group(1)!, "this")
    XCTAssertEqual(match.group(2)!, "that")
    XCTAssertEqual(match.span()!, string.startIndex.advancedBy(4)..<string.startIndex.advancedBy(38))
    XCTAssertEqual(match.span(1)!, string.startIndex.advancedBy(4)..<string.startIndex.advancedBy(8))
    XCTAssertEqual(match.span(2)!, string.startIndex.advancedBy(31)..<string.startIndex.advancedBy(35))
  }
  
  func testMatchFailure() {
    let regex = re.compile("(this).+(that)")
    let string = " this one is different from that one."
    let match = regex.match(string)
    XCTAssertNil(match)
  }
  
  func testSearchSuccess() {
    let regex = re.compile("(this).+(that)")
    let string = "this one is different from that one."
    let m = regex.search(string)
    XCTAssertTrue(m != nil)
    let match = m!
    XCTAssertEqual(match.string, string)
    XCTAssertEqual(match.group()!, "this one is different from that")
    XCTAssertEqual(match.group(1)!, "this")
    XCTAssertEqual(match.group(2)!, "that")
    XCTAssertEqual(match.span()!, string.startIndex..<string.startIndex.advancedBy(31))
    XCTAssertEqual(match.span(1)!, string.startIndex..<string.startIndex.advancedBy(4))
    XCTAssertEqual(match.span(2)!, string.startIndex.advancedBy(27)..<string.startIndex.advancedBy(31))
  }
  
  func testSearchWithRangeSuccess() {
    let regex = re.compile("(this).+(that) .*")
    let string = "omg this one is different from that one."
    let m = regex.search(string, 4, 38)
    XCTAssertNotNil(m)
    let match = m!
    XCTAssertEqual(match.string, string)
    XCTAssertEqual(match.group()!, "this one is different from that on")
    XCTAssertEqual(match.group(1)!, "this")
    XCTAssertEqual(match.group(2)!, "that")
    XCTAssertEqual(match.span()!, string.startIndex.advancedBy(4)..<string.startIndex.advancedBy(38))
    XCTAssertEqual(match.span(1)!, string.startIndex.advancedBy(4)..<string.startIndex.advancedBy(8))
    XCTAssertEqual(match.span(2)!, string.startIndex.advancedBy(31)..<string.startIndex.advancedBy(35))
  }
  
  func testSearchNestGroupsSuccess() {
    let regex = re.compile("((\\s*this\\s*)+).+?((\\s*that\\s*)+)")
    let string = "this this this one is different from that that that one."
    let m = regex.search(string)
    XCTAssertNotNil(m)
    let match = m!
    XCTAssertEqual(match.string, string)
    XCTAssertEqual(match.group()!, "this this this one is different from that that that ")
    XCTAssertEqual(match.group(1)!, "this this this ")
    XCTAssertEqual(match.group(2)!, "this ")
    XCTAssertEqual(match.group(3)!, " that that that ")
    XCTAssertEqual(match.group(4)!, "that ")
    XCTAssertEqual(match.span()!, string.startIndex..<string.startIndex.advancedBy(52))
    XCTAssertEqual(match.span(1)!, string.startIndex..<string.startIndex.advancedBy(15))
    XCTAssertEqual(match.span(2)!, string.startIndex.advancedBy(10)..<string.startIndex.advancedBy(15))
    XCTAssertEqual(match.span(3)!, string.startIndex.advancedBy(36)..<string.startIndex.advancedBy(52))
    XCTAssertEqual(match.span(4)!, string.startIndex.advancedBy(47)..<string.startIndex.advancedBy(52))
  }
  
  func testFindallSuccess() {
    let regex = re.compile("([abc]+[123]+)")
    let string = "abcd1234-aab113-abc333-adbca3432ddbca332233"
    let matches = regex.findall(string)
    XCTAssertEqual(matches.count, 4)
    XCTAssertEqual(matches, ["aab113", "abc333", "bca3", "bca332233"])
  }
  
  func testFindallSuccessWithPos() {
    let regex = re.compile("([abc]+[123]+)")
    let string = "abcd1234-aab113-abc333-adbca3432ddbca332233"
    let matches = regex.findall(string, 21)
    XCTAssertEqual(matches.count, 2)
    XCTAssertEqual(matches, ["bca3", "bca332233"])
  }
  
  func testFindIterSuccess() {
    let regex = re.compile("([abc]+[123]+)")
    let string = "abcd1234-aab113-abc333-adbca3432ddbca332233"
    let matches = regex.finditer(string)
    XCTAssertEqual(matches.count, 4)
    let expectations = ["aab113", "abc333", "bca3", "bca332233"];
    for (index, expectation) in expectations.enumerate() {
      let group: String? = matches[index].group()
      XCTAssertNotNil(group)
      XCTAssertEqual(group!, expectation)
    }
  }
  
  func testFindIterSuccessWithPos() {
    let regex = re.compile("([abc]+[123]+)")
    let string = "abcd1234-aab113-abc333-adbca3432ddbca332233"
    let matches = regex.finditer(string, 9, 21)
    XCTAssertEqual(matches.count, 2)
    let expectations = ["aab113", "abc33"];
    for (index, expectation) in expectations.enumerate() {
      let group: String? = matches[index].group()
      XCTAssertNotNil(group)
      XCTAssertEqual(group!, expectation)
    }
  }
  
  func testSplitSuccess() {
    let regex = re.compile("[,.]")
    let string = "saldkfjalskfd,sdfjlskdfjl.//.sldkfjlskdfj,.sdjflksd."
    let substrings = regex.split(string)
    XCTAssertEqual(substrings.count, 7)
    XCTAssertTrue(substrings == ["saldkfjalskfd", "sdfjlskdfjl", "//", "sldkfjlskdfj", "", "sdjflksd", ""] as [String?])
  }
  
  func testSplitWithMaxSplitSuccess() {
    let regex = re.compile("[,.]")
    let string = "saldkfjalskfd,sdfjlskdfjl.//.sldkfjlskdfj,.sdjflksd."
    let substrings = regex.split(string, 5)
    XCTAssertEqual(substrings.count, 6)
    XCTAssertTrue(substrings == ["saldkfjalskfd", "sdfjlskdfjl", "//", "sldkfjlskdfj", "", "sdjflksd."] as [String?])
  }
  
  func testSplitWithGroups() {
    let regex = re.compile("([,.])")
    let string = "saldkfjalskfd,sdfjlskdfjl.//.sldkfjlskdfj,.sdjflksd."
    let substrings = regex.split(string)
    XCTAssertEqual(substrings.count, 13)
    XCTAssertTrue(substrings == ["saldkfjalskfd", ",", "sdfjlskdfjl", ".", "//", ".", "sldkfjlskdfj", ",", "", ".", "sdjflksd", ".", ""] as [String?])
  }
  
  func testSubSuccess() {
    let regex = re.compile("[sS]oviet")
    let string = "Soviet will surely win the war, let's cheer for the great soviet"
    let subbed = regex.sub("Allies", string)
    XCTAssertEqual(subbed, "Allies will surely win the war, let's cheer for the great Allies")
  }
  
  func testSubNoOccurrence() {
    let regex = re.compile("[sS]oviet")
    let string = "Allies will surely win the war, let's cheer for the great Allies"
    let subbed = regex.sub("Allies", string)
    XCTAssertEqual(subbed, string)
  }
  
  func testSubWithCount() {
    let regex = re.compile("[sS]oviet")
    let string = "Soviet will surely win the war, let's cheer for the great soviet"
    XCTAssertEqual(regex.sub("Allies", string, 1), "Allies will surely win the war, let's cheer for the great soviet")
    XCTAssertEqual(regex.sub("Allies", string, 2), "Allies will surely win the war, let's cheer for the great Allies")
    XCTAssertEqual(regex.sub("Allies", string, -1), string)
  }
  
  func testSubWithCaptureGroups() {
    let regex = re.compile("(Soviet)(.*)(Allies)")
    let string = "Soviet will beat Allies"
    XCTAssertEqual(regex.sub("$3$2$1", string), "Allies will beat Soviet")
  }
  
  func testCompileInvalidPattern() {
    let regex = re.compile("(")
    XCTAssertFalse(regex.isValid)
    XCTAssertNil(regex.search("test") as? AnyObject)
    XCTAssertNil(regex.match("test") as? AnyObject)
    XCTAssertNil(regex.nsRegex)
    XCTAssertTrue(regex.split("sdf(sdf") == [])
    XCTAssertEqual(regex.sub("o", "hahaha("), "hahaha(")
    XCTAssertEqual(regex.subn("o", "hahaha(").1, 0)
  }
}
