//
//  OffsetRange.swift
//  Taylor
//
//  Created by Alexandru Culeva on 4/12/16.
//  Copyright © 2016 YOPESO. All rights reserved.
//

import Foundation

struct OffsetRange {
    var start: Int
    var end: Int
    
    init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}

extension OffsetRange {
    static let zero = OffsetRange(start: 0, end: 0)
}

extension OffsetRange: Comparable { }

func ==(lhs: OffsetRange, rhs: OffsetRange) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}

func <(lhs: OffsetRange, rhs: OffsetRange) -> Bool {
    return lhs.start < rhs.start
}

extension OffsetRange: RangeType {
    init(range: NSRange) {
        start = range.location
        end = range.location + range.length
    }
}

extension OffsetRange {
    func toEmptyLineRange() -> OffsetRange {
        return OffsetRange(start: self.start + 1, end: self.end - 1)
    }
}

/// Returns true if **left** range contains **right** range.
func ~= (_ lhs: OffsetRange, _ rhs: OffsetRange) -> Bool {
    return lhs.start <= rhs.start && lhs.end >= rhs.end
}
