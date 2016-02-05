//
//  ScissorsExtensions.swift
//  Scissors
//
//  Created by Alex Culeva on 9/18/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SwiftXPC
import SourceKittenFramework

//MARK: BoundariesKit extensions
let types = [
    "source.lang.swift.decl.class": ComponentType.Class,
    "source.lang.swift.decl.struct": .Struct,
    "source.lang.swift.decl.enum": .Enum,
    "source.lang.swift.decl.protocol": .Protocol,
    "source.lang.swift.decl.function.method.instance": .Function,
    "source.lang.swift.decl.function.method.static": .Function,
    "source.lang.swift.decl.function.method.class": .Function,
    "source.lang.swift.decl.function.accessor.getter": .Function,
    "source.lang.swift.decl.function.accessor.setter": .Function,
    "source.lang.swift.decl.function.accessor.willset": .Function,
    "source.lang.swift.decl.function.accessor.didset": .Function,
    "source.lang.swift.decl.function.accessor.address": .Function,
    "source.lang.swift.decl.function.accessor.mutableaddress": .Function,
    "source.lang.swift.decl.function.constructor": .Function,
    "source.lang.swift.decl.function.destructor": .Function,
    "source.lang.swift.decl.function.free": .Function,
    "source.lang.swift.decl.function.accessor.operator": .Function,
    "source.lang.swift.decl.function.accessor.subscript": .Function,
    "source.lang.swift.decl.var.parameter": .Parameter,
    "source.lang.swift.decl.extension": .Extension,
    "source.lang.swift.decl.extension.struct": .Extension,
    "source.lang.swift.decl.extension.class": .Extension,
    "source.lang.swift.decl.extension.enum": .Extension,
    "source.lang.swift.decl.extension.protocol": .Extension,
    "source.lang.swift.stmt.for": .For,
    "source.lang.swift.stmt.foreach": .For,
    "source.lang.swift.stmt.if": .If,
    "source.lang.swift.stmt.guard": .Guard,
    "source.lang.swift.stmt.repeatwhile": .Repeat,
    "source.lang.swift.stmt.while": .While,
    "source.lang.swift.stmt.switch": .Switch,
    "source.lang.swift.stmt.case": .Case,
    "source.lang.swift.stmt.brace": .Brace,
    "source.lang.swift.syntaxtype.comment": .Comment,
    "source.lang.swift.syntaxtype.doccomment": .Comment,
    "source.lang.swift.decl.var.instance": .Variable,
    "source.lang.swift.decl.var.global": .Variable,
    "source.lang.swift.expr.call": .Closure
]

extension ComponentType {
    init(type: String) {
        self = types[type] ?? .Other
    }
}

extension ComponentType {
    var isOther: Bool { return self == .Other }
    var isBrace: Bool { return self == .Brace }
    var isVariable: Bool { return self == .Variable }
    var isComment: Bool { return self == .Comment }
    var isEmptyLine: Bool { return self == .EmptyLines }
}

//MARK: SwiftXPC extensions

protocol StringType {}
extension String: StringType {}

extension XPCRepresentable {
    var asDictionary: XPCDictionary { return self as! XPCDictionary }
}

protocol XPCType {
    var value: XPCDictionary { get }
}

extension Dictionary where Key: StringType {
    var offsetRange: OffsetRange {
        let startOffset = SwiftDocKey.getOffset(self.asDictionary) ?? 0
        let length = SwiftDocKey.getLength(self.asDictionary) ?? 0
        let endOffset = Int(startOffset + length)
        return OffsetRange(start: Int(startOffset), end: endOffset)
    }
    var typeName: String? { return SwiftDocKey.getTypeName(self.asDictionary) }
    var name: String? { return SwiftDocKey.getName(self.asDictionary) }
    var substructure: XPCArray { return SwiftDocKey.getSubstructure(self.asDictionary) ?? [] }
    var type: String { return SwiftDocKey.getKind(self.asDictionary) ?? "" }
    var bodyLength: Int { return Int(SwiftDocKey.getBodyLength(self.asDictionary) ?? 0) }
    var bodyOffset: Int { return Int(SwiftDocKey.getBodyOffset(self.asDictionary) ?? 0) }
}

extension File {
    
    var endOffset: Int {
        return startOffset + size + 1
    }
    
    func chunkSize(numberOfLines: Int) -> Int {
        func numberOfCharacters(m m: Double, b: Double) -> Int {
            return Double(numberOfLines).linearFunction(slope: m, intercept: b).intValue
        }
        
        if numberOfLines < 500 { return contents.characters.count }
        if numberOfLines < 1000 { return numberOfCharacters(m: 4, b: -500) }
        if numberOfLines < 2000 { return numberOfCharacters(m: 1.5, b: 2000) }
        if numberOfLines < 3000 { return numberOfCharacters(m: 1, b: 3000) }
        return numberOfCharacters(m: 0.6, b: 4200)
    }
    
    
    func divideByLines() -> [File] {
        guard chunkSize(lines.count) > 0 else { return [self] }
        let numberOfChunks = contents.characters.count / chunkSize(lines.count)
        if numberOfChunks <= 1 { return [self] }
        let chunks = lines.chunk(numberOfChunks)
        
        return chunks.reduce([File]()) { (files: [File], lines: [Line]) -> [File] in
            let offset =  files.last?.endOffset ?? 0
            return files + File(lines: lines.map { $0.content },
                startLine: lines[0].index,
                startOffset: offset)
        }
    }
    
    func getLineRange(offset: Int) -> Int {
        return startLine + getLineByOffset(offset - startOffset, length: 0).0 - 1
    }
}

func + (var lhs: [File], rhs: File) -> [File] {
    lhs.append(rhs)
    return lhs
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

//MARK: ExtendedComponent extensions

extension ExtendedComponent {
    var isElseIfOrIf: Bool { return self.type == .If || self.type == .ElseIf }
    var children: Int { return self.components.count }
    var containsClosure: Bool {
        return self.components.filter(){ $0.type == ComponentType.Closure }.count > 0
    }
    
    var isCorrectParameter: Bool {
        guard self.isParameter else { return true }
        guard name != nil else { return true }
        let startsWithDollar = name![name!.startIndex] == "$"
        
        if typeName == nil {
            return !startsWithDollar || parent!.isClosure
        } else {
            return (!startsWithDollar && name != typeName) || parent!.isClosure
        }
    }
    
    var containsParameter: Bool {
        return self.components.filter(){ $0.type == ComponentType.Parameter }.count > 0
    }
    
    var hasNoChildrenExceptELComment: Bool {
        return self.components.filter() { !$0.type.isComment && !$0.type.isEmptyLine }.count > 0 && self.type == .Variable
    }
    
    var isActuallyClosure: Bool {
        return self.children == 1 && self.containsClosure
    }
    
    var isParameter: Bool {
        return type == .Parameter
    }
    
    var isClosure: Bool {
        return type == .Closure
    }
    
    var isFirstComponentBrace: Bool {
        guard self.components.count > 0 else {
            return false
        }
        return self.components[0].type == .Brace
    }
    
    func insert(components: [ExtendedComponent]) {
        components.forEach {
            self.insert($0)
        }
    }
    
    func isElseIf(type: ComponentType) -> Bool {
        return type == .If && self.isElseIfOrIf
    }
    
    func isElse(type: ComponentType) -> Bool {
        return type == .Brace && self.isElseIfOrIf
    }
    
    func changeChildToParent(index: Int) {
        parent?.addChild(components[index])
        components.removeAtIndex(index)
    }
    
    func takeChildrenOfChild(index: Int) {
        for child in components[index].components {
            addChild(child)
        }
    }
    
    func addChild(child: ExtendedComponent) -> ExtendedComponent {
        self.components.append(child)
        child.parent = self
        return child
    }
    
    func addChild(type: ComponentType, range: OffsetRange, name: String? = nil) -> ExtendedComponent {
        let child = ExtendedComponent(type: type, range: range, names: (name, nil))
        child.parent = self
        self.components.append(child)
        return child
    }
    
    func contains(node: ExtendedComponent) -> Bool {
        return (node.offsetRange.start >= self.offsetRange.start)
            && (node.offsetRange.end <= self.offsetRange.end)
    }
    
    func insert(node: ExtendedComponent) {
        for child in self.components {
            if child.contains(node) {
                child.insert(node)
                return
            } else if node.contains(child) {
                remove(child)
                node.addChild(child)
            }
        }
        self.addChild(node)
    }
    
    func processParameters() {
        for child in components {
            if isParameter && child.isParameter {
                if offsetRange == child.offsetRange {
                    remove(child)
                    parent?.addChild(child)
                } else {
                    parent?.addChild(child)
                    parent?.remove(self)
                    child.processParameters()
                    break
                }
            }
            child.processParameters()
        }
    }
    
    func removeRedundantClosures() {
        for component in components {
            component.removeRedundantClosures()
        }
        removeRedundantClosuresInSelf()
    }
    
    func removeRedundantClosuresInSelf() {
        components = components.filter() {
            !($0.type == .Closure && $0.components.isEmpty)
        }
    }
    
    func removeRedundantParameters() {
        for child in components {
            if !child.isCorrectParameter {
                remove(child)
            } else {
                child.removeRedundantParameters()
            }
        }
    }
    
    func remove(component: ExtendedComponent) {
        components = components.filter() { $0 != component }
    }
}

extension ExtendedComponent : Hashable {
    var hashValue: Int {
        let initialValue = offsetRange.start.hashValue + offsetRange.end.hashValue + type.hashValue
        return components.reduce(initialValue) { $0 + $1.hashValue }
    }
}

extension ExtendedComponent : Equatable {}
func ==(lhs: ExtendedComponent, rhs: ExtendedComponent) -> Bool {
    if !(lhs.offsetRange == rhs.offsetRange) { return false }
    if lhs.type != rhs.type { return false }
    
    return Set(lhs.components) == Set(rhs.components)
}

func ==(lhs: OffsetRange, rhs: OffsetRange) -> Bool {
    return lhs.end == rhs.end && lhs.start == rhs.start
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
            return regex.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)).map {
                T(range: $0.range)
            }
        } catch { return [] }
    }
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
