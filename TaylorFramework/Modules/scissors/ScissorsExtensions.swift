//
//  ScissorsExtensions.swift
//  Scissors
//
//  Created by Alex Culeva on 9/18/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework

extension ComponentType {
    func isA(type: ComponentType) -> Bool { return self == type }
}

//MARK: SwiftXPC extensions

protocol StringType {}
extension String: StringType {}

extension SourceKitRepresentable {
    var dictionaryValue: [String: SourceKitRepresentable] {
        return self as? [String: SourceKitRepresentable] ?? [:]
    }
}

protocol XPCType {
    var value: SourceKitRepresentable { get }
}

extension Dictionary where Key: StringType {
    var offsetRange: OffsetRange {
        let startOffset = SwiftDocKey.publicGetOffset(dictionaryValue) ?? 0
        let length = SwiftDocKey.publicGetLength(dictionaryValue) ?? 0
        let endOffset = Int(startOffset + length)
        return OffsetRange(start: Int(startOffset), end: endOffset)
    }
    var typeName: String? { return SwiftDocKey.publicGetTypeName(dictionaryValue) }
    var name: String? { return SwiftDocKey.getName(dictionaryValue) }
    var substructure: [SourceKitRepresentable] { return SwiftDocKey.publicGetSubstructure(dictionaryValue) ?? [] }
    var type: String { return SwiftDocKey.publicGetKind(dictionaryValue) ?? "" }
    var bodyLength: Int { return Int(SwiftDocKey.publicGetBodyLength(dictionaryValue) ?? 0) }
    var bodyOffset: Int { return Int(SwiftDocKey.publicGetBodyOffset(dictionaryValue) ?? 0) }
}

extension Array {
    /// Creates an array of elements split into groups the length of size.
    /// If array can’t be split evenly, the final chunk will be the remaining elements.
    ///
    /// :param array to chunk
    /// :param size size of each chunk
    /// :return array elements chunked
    func chunk(size: Int = 1) -> [[Element]] {
        var result = [[Element]]()
        var chunk = -1
        for (index, elem) in self.enumerate() {
            if index % size == 0 {
                result.append([Element]())
                chunk += 1
            }
            result[chunk].append(elem)
        }
        return result
    }
}

struct FileInfo {
    let startOffset: Int
    let startLine: Int
    let lines: Int
}

extension Component {
    func isA(otherType: ComponentType) -> Bool { return self.type.isA(otherType) }
}

//MARK: Linear function on double x

extension Double {
    var intValue: Int {
        return Int(self)
    }
    
    func linearFunction(slope slope: Double, intercept: Double) -> Double {
        return slope * self + intercept
    }
}

//MARK: Operators overloading

/**
Returns new string consisting of rhs copies of lhs concatenated.

- parameter lhs: string to be repeated.

- parameter rhs: number of times of *lhs* to be concatenated.
*/
func *(lhs: String, rhs: Int) -> String {
    return (0..<rhs).reduce("") { (string, _) in string + lhs }
}

protocol RangeType {
    init(range: NSRange)
}

extension String {
    func findMatchRanges<T: RangeType>(pattern: String) -> [T] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.DotMatchesLineSeparators])
            return regex.matchesInString(self, options: [], range: NSMakeRange(0, characters.count)).map {
                T(range: $0.range)
            }
        } catch { return [] }
    }
}

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    mutating func shuffleInPlace() {
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
