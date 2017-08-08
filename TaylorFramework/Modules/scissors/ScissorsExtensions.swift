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
    func isA(_ type: ComponentType) -> Bool { return self == type }
}

//MARK: SwiftXPC extensions

protocol StringType {}
extension String: StringType {
    func substring(with r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.index(self.startIndex, offsetBy: r.upperBound)
        
        return String(self[start...end])
    }
}

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
        let startOffset = SwiftDocKey.publicGetOffset(dictionary: dictionaryValue) ?? 0
        let length = SwiftDocKey.publicGetLength(dictionary: dictionaryValue) ?? 0
        let endOffset = Int(startOffset + length)
        return OffsetRange(start: Int(startOffset), end: endOffset)
    }
    var bodyRange: OffsetRange {
        let start = SwiftDocKey.publicGetBodyOffset(dictionary: dictionaryValue) ?? 0
        let length = SwiftDocKey.publicGetBodyLength(dictionary: dictionaryValue) ?? 0

        return OffsetRange(start: Int(start), end: Int(start + length - 1))
    }
    var typeName: String? { return SwiftDocKey.publicGetTypeName(dictionary: dictionaryValue) }
    var name: String? { return SwiftDocKey.getName(dictionary: dictionaryValue) }
    var substructure: [SourceKitRepresentable] {
        var dictionary = dictionaryValue
        guard let _ = dictionary[SwiftDocKey.substructure.rawValue] as? [SourceKitRepresentable] else { return [] }
        return SwiftDocKey.publicGetSubstructure(dictionary: dictionary) ?? []
    }
    var type: String { return SwiftDocKey.publicGetKind(dictionary: dictionaryValue) ?? "" }
    var bodyLength: Int { return Int(SwiftDocKey.publicGetBodyLength(dictionary: dictionaryValue) ?? 0) }
    var bodyOffset: Int { return Int(SwiftDocKey.publicGetBodyOffset(dictionary: dictionaryValue) ?? 0) }
}

extension Array {
    /// Creates an array of elements split into groups the length of size.
    /// If array can’t be split evenly, the final chunk will be the remaining elements.
    ///
    /// :param array to chunk
    /// :param size size of each chunk
    /// :return array elements chunked
    func chunk(_ size: Int = 1) -> [[Element]] {
        var result = [[Element]]()
        var chunk = -1
        for (index, elem) in self.enumerated() {
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
    func isA(_ otherType: ComponentType) -> Bool { return self.type.isA(otherType) }
}

//MARK: Linear function on double x

extension Double {
    var intValue: Int {
        return Int(self)
    }
    
    func linearFunction(slope: Double, intercept: Double) -> Double {
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
    func findMatchRanges<T: RangeType>(_ pattern: String) -> [T] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
            return regex.matches(in: self, options: [], range: NSMakeRange(0, characters.count)).map {
                T(range: $0.range)
            }
        } catch { return [] }
    }
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    mutating func shuffleInPlace() {
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            guard i != j else { continue }
            swapAt(i, j)
        }
    }
}
