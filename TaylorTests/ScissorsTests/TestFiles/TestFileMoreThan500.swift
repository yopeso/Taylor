//
//  ExtendedComponent.swift
//  Scissors
//
//  Created by Alex Culeva on 9/17/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework
import SwiftXPC

class ExtendedComponent {
    var offsetRange: OffsetRange
    var type: ComponentType
    var name: String?
    var parent: ExtendedComponent?
    var components: [ExtendedComponent]
    
    init(type: ComponentType, range: OffsetRange, name: String? = nil, parent: ExtendedComponent? = nil) {
        self.type = type
        self.offsetRange = range
        self.parent = parent
        self.components = []
        self.name = name
    }
    
    init(dict: [String: AnyObject]) {
        self.type = ComponentType(type: dict["type"] as! String)
        let startOffset = dict["offset"] as! Int
        let endOffset = startOffset + (dict["length"] as! Int)
        self.offsetRange = OffsetRange(start: startOffset, end: endOffset - 1)
        self.name = nil
        self.components = []
    }
    
    func appendComponents(var components: [ExtendedComponent], array: XPCArray) -> [ExtendedComponent] {
        var braces = 0
        for (var childNumber = 0; childNumber < array.count; childNumber++) {
            let structure = array[childNumber]
            let typeString = structure.asDictionary.type
            
            var offsetRange = structure.asDictionary.offsetRange
            var componentType = ComponentType(type: typeString)
            if isElseIf(componentType) { componentType = .ElseIf }
            else if isElse(componentType) && childNumber == array.count-1 && braces > 0 { componentType = .Else }
            else if componentType.isVariable {
                let bodyOffsetEnd = structure.asDictionary.bodyLength + structure.asDictionary.bodyOffset
                if bodyOffsetEnd != 0 {
                    offsetRange.end = bodyOffsetEnd
                }
            }
            else if componentType.isOther { continue }
            if componentType.isBrace { braces++ }
            
            let child = ExtendedComponent(type: componentType, range: offsetRange, name: structure.asDictionary.name)
            components.append(child)
            components = child.appendComponents(components, array: structure.asDictionary.substructure)
        }
        
        return components
    }
    
    func addChild(child: ExtendedComponent) -> ExtendedComponent {
        self.components.append(child)
        child.parent = self
        return child
    }
    
    func addChild(type: ComponentType, range: OffsetRange, name: String? = nil) -> ExtendedComponent {
        let child = ExtendedComponent(type: type, range: range, name: name, parent: self)
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
    
    func remove(component: ExtendedComponent) {
        components = components.filter() { $0 != component }
    }
    
    func insert(components: [ExtendedComponent]) {
        let _ = components.map {
            self.insert($0)
        }
    }
    
    
    func variablesToFunctions() {
        for component in self.components {
            if component.hasNoChildrenExceptELComment {
                if component.isActuallyClosure {
                    component.components[0].name = component.name
                    component.parent?.components.append(component.components[0])
                    component.parent?.remove(component)
                }
                component.type = ComponentType.Function
            } else if component.type == .Brace && component.containsParameter {
                component.type = .Closure
            }
            component.variablesToFunctions()
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
            !($0.type == .Closure && $0.components.count == 0)
        }
    }
    
    func processBracedType() {
        if self.children > 1 {
            self.changeChildToParent(1)
        }
        self.takeChildrenOfChild(0)
        if type != .Repeat {
            self.offsetRange.end = self.components[0].offsetRange.end
        }
        self.components.removeAtIndex(0)
    }
    
    func sortChildren() {
        self.components = self.components.sort({ $0.offsetRange.start < $1.offsetRange.start })
    }
}

struct OffsetRange {
    var start: Int
    var end: Int
    
    init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}
//
//  Tree.swift
//  Scissors
//
//  Created by Alex Culeva on 9/14/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import BoundariesKit
import SwiftXPC
import SourceKittenFramework

class Tree {
    let file: File
    let dictionary: XPCDictionary
    let syntaxMap: SyntaxMap
    let parts: [File]
    
    init(file: File) {
        let structure = Structure(file: file)
        self.file = file
        dictionary = structure.dictionary
        syntaxMap = structure.syntaxMap
        self.parts = file.divideByLines()
    }
    
    //MARK: Dictionary to tree methods
    
    func makeTree() -> Component {
        let root = ExtendedComponent(type: .Other, range: dictionary.offsetRange)
        let noStringsText = replaceStringsWithSpaces(parts.map() { $0.contents })
        
        let finder = Finder(text: noStringsText, syntaxMap: syntaxMap)
        var componentsArray = root.appendComponents([], array: dictionary.substructure)
        componentsArray += finder.findGetters(componentsArray)
        arrayToTree(componentsArray, root: root)
        root.removeRedundantClosures()
        processBraces(root)
        arrayToTree(additionalComponents(finder), root: root)
        root.variablesToFunctions()
        sortTree(root)
        
        return convertTree(root)
    }
    
    func additionalComponents(finder: Finder) -> [ExtendedComponent] {
        return finder.findComments() + finder.findLogicalOperators() + finder.findEmptyLines()
    }
    
    //MARK: Conversion to Component type
    
    func convertTree(root: ExtendedComponent) -> Component {
        let rootComponent = Component(type: root.type, range: ComponentRange(sl: 1, el: file.lines.count))
        convertToComponent(root, componentNode: rootComponent)
        
        return rootComponent
    }
    
    func convertToComponent(node: ExtendedComponent, componentNode: Component) {
        for component in node.components {
            let child = componentNode.makeComponent(type: component.type,
                range: offsetToLine(component.offsetRange))
            child.name = component.name
            convertToComponent(component, componentNode: child)
        }
    }
    
    func offsetToLine(offsetRange: OffsetRange) -> ComponentRange {
        //        guard parts[0].size > 0 else {
        //            return ComponentRange(sl: 0, el: 0)
        //        }
        
        let startIndex = parts.filter() { $0.startOffset <= offsetRange.start }.count - 1
        let endIndex = parts.filter() { $0.startOffset <= offsetRange.end }.count - 1
        
        
        return ComponentRange(sl: parts[startIndex].getLineRange(offsetRange.start), el: parts[endIndex].getLineRange(offsetRange.end))
    }
    
    func arrayToTree(components: [ExtendedComponent], root: ExtendedComponent) -> ExtendedComponent {
        let parent = root
        parent.insert(components)
        
        return parent
    }
    
    //MARK: Processing the tree
    
    func processBraces(parent: ExtendedComponent) {
        var i = 0
        while i < parent.components.count {
            let component = parent.components[i]; i++
            let type = component.type
            let bracedTypes = [ComponentType.If, .ElseIf, .For, .While, .Repeat, .Closure]
            if bracedTypes.contains(type)  {
                guard component.isFirstComponentBrace else {
                    continue
                }
                component.processBracedType()
            }
            processBraces(component)
        }
    }
    
    func sortTree(root: ExtendedComponent) {
        for component in root.components {
            sortTree(component)
            component.sortChildren()
        }
    }
    
    //MARK: Text filtering methods
    
    func replaceStringsWithSpaces(text: [String]) -> String {
        var noStrings = ""
        for var part in text {
            if part.isEmpty { continue }
            for string in re.findall("\\\".*?\\\"", part, flags: [NSRegularExpressionOptions.DotMatchesLineSeparators]) {
                let len = string.characters.count
                part = part.stringByReplacingOccurrencesOfString(string, withString: " "*len)
            }
            noStrings += part + "\n"
        }
        return noStrings
    }
}
//
//  Finder.swift
//  Scissors
//
//  Created by Alex Culeva on 10/2/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework
import BoundariesKit

class Finder {
    let text: String
    let syntaxMap: SyntaxMap
    init(text: String, syntaxMap: SyntaxMap = SyntaxMap(tokens: [])) {
        self.text = text
        self.syntaxMap = syntaxMap
    }
    
    func findRanges(pattern: String, text: String) -> [OffsetRange] {
        var ranges = [OffsetRange]()
        let r = re.compile(pattern, flags: [.DotMatchesLineSeparators])
        for match in r.finditer(text) {
            if let range = match.spanNSRange() {
                ranges.append(OffsetRange(start: range.location, end: range.location+range.length))
            }
        }
        return ranges
    }
    
    func findLogicalOperators() -> [ExtendedComponent] {
        var operators = [ExtendedComponent]()
        
        for ternaryRange in findRanges("(\\s+\\?(?!\\?).*?:)", text: text) {
            operators.append(ExtendedComponent(type: .Ternary, range: ternaryRange))
        }
        for nilcRange in findRanges("(\\?\\?)", text: text) {
            operators.append(ExtendedComponent(type: .NilCoalescing, range: nilcRange))
        }
        for orRange in findRanges("(\\|\\|)", text: text) {
            operators.append(ExtendedComponent(type: .Or, range: orRange))
        }
        for andRange in findRanges("(\\&\\&)", text: text) {
            operators.append(ExtendedComponent(type: .And, range: andRange))
        }
        
        return operators
    }
    
    func findComments() -> [ExtendedComponent] {
        var components = [ExtendedComponent]()
        for token in syntaxMap.tokens {
            if ComponentType(type: token.type) == ComponentType.Comment {
                components.append(ExtendedComponent(dict: token.dictionaryValue))
            }
        }
        return components
    }
    
    func findEmptyLines() -> [ExtendedComponent] {
        var emptyLines = [ExtendedComponent]()
        for emptyLineRange in findRanges("(\\n[ \\t\\n]*\\n)", text: text) {
            let correctEmptyRange = OffsetRange(start: emptyLineRange.start + 1, end: emptyLineRange.end - 1)
            emptyLines.append(ExtendedComponent(type: .EmptyLines, range: correctEmptyRange))
        }
        
        return emptyLines
    }
    
    //Ending points of getters and setters will most probably be wrong unless a nice coding-style is being used "} set {"
    func findGetters(components: [ExtendedComponent]) -> [ExtendedComponent] {
        let variableComponents = components.filter() { $0.type == .Variable }
        let nsText = text as NSString
        var getters = [ExtendedComponent]()
        for component in variableComponents {
            let range = NSMakeRange(component.offsetRange.start, component.offsetRange.end - component.offsetRange.start)
            let variableText = nsText.substringWithRange(range)
            let functions = findGetterAndSetter(variableText)
            for function in functions {
                function.offsetRange.start += component.offsetRange.start
                function.offsetRange.end += component.offsetRange.start
                getters.append(function)
            }
        }
        return getters
    }
    
    func findGetterAndSetter(text: String) -> [ExtendedComponent] {
        var accessors = [ExtendedComponent]()
        let gettersRanges = findRanges("(get($|[ \\t\\n{}]))", text: text)
        let settersRanges = findRanges("(set($|[ \\t\\n{}]))", text: text)
        if gettersRanges.count == 0 {
            return findObserverGetters(text)
        }
        accessors.append(ExtendedComponent(type: .Function, range: gettersRanges[0], name: "get", parent: nil))
        if settersRanges.count > 0 {
            accessors.append(ExtendedComponent(type: .Function, range: settersRanges[0], name: "set", parent: nil))
        }
        accessors.sortInPlace( { $0.offsetRange.start < $1.offsetRange.start } )
        if accessors.count == 1 {
            accessors[0].offsetRange.end = text.characters.count - 1
        } else {
            accessors[0].offsetRange.end = accessors[1].offsetRange.start - 1
            accessors[1].offsetRange.end = text.characters.count - 1
        }
        
        return accessors
    }
    
    func findObserverGetters(text:String) -> [ExtendedComponent] {
        var willSetRanges = findRanges("(willSet($|[ \\t\\n{}]))", text: text)
        var didSetRanges = findRanges("(didSet($|[ \\t\\n{}]))", text: text)
        var observers = [ExtendedComponent]()
        if willSetRanges.count > 0 {
            observers.append(ExtendedComponent(type: .Function, range: willSetRanges[0], name: "willSet", parent: nil))
        }
        if didSetRanges.count > 0 {
            observers.append(ExtendedComponent(type: .Function, range: didSetRanges[0], name: "didSet", parent: nil))
        }
        observers.sortInPlace( { $0.offsetRange.start < $1.offsetRange.start } )
        switch observers.count {
        case 0: return []
        case 1: observers[0].offsetRange.end = text.characters.count - 1
        case 2: observers[0].offsetRange.end = observers[1].offsetRange.start - 1
        observers[1].offsetRange.end = text.characters.count - 1
        default: break
        }
        
        return observers
    }
}
//
//  Extensions.swift
//  Scissors
//
//  Created by Alex Culeva on 9/18/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import BoundariesKit
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
    var name: String? { return SwiftDocKey.getName(self.asDictionary) }
    var substructure: XPCArray { return SwiftDocKey.getSubstructure(self.asDictionary) ?? [] }
    var type: String { return SwiftDocKey.getKind(self.asDictionary) ?? "" }
    var bodyLength: Int { return Int(SwiftDocKey.getBodyLength(self.asDictionary) ?? 0) }
    var bodyOffset: Int { return Int(SwiftDocKey.getBodyOffset(self.asDictionary) ?? 0) }
}

extension File {
    
    func chunkSize(numberOfLines: Int) -> Int {
        func numberOfCharacters(m m: Double, b: Double) -> Int {
            return Double(numberOfLines).linearFunction(slope: m, intercept: b).intValue
        }
        
        if numberOfLines < 500 { return contents.characters.count }
        if numberOfLines < 1000 { return numberOfCharacters(m: 0.8, b: 0) }
        if numberOfLines < 2000 { return numberOfCharacters(m: 0.45, b: 350) }
        if numberOfLines < 3000 { return numberOfCharacters(m: 0.2, b: 850) }
        else { return numberOfCharacters(m: 0.18, b: 900) }
    }
    
    func divideByLines() -> [File] {
        guard chunkSize(lines.count) > 0 else {
            return [self]
        }
        let partitions = contents.characters.count / chunkSize(lines.count)
        if partitions <= 1 {
            return [self]
        }
        let size = lines.count / partitions
        var temporaryParts = [File]()
        var startOffset = 0
        for(var i = 0; i < partitions; i++) {
            let slice = lines.part(from: i * size, to: i == partitions - 1 ? lines.count : (i + 1) * size)
            let file = File(lines: slice.map() { $0.content }, startLine: i * size + 1, startOffset: startOffset)
            temporaryParts.append(file)
            startOffset += file.contents.characters.count
        }
        return temporaryParts
    }
    
    func getLineRange(offset: Int) -> Int {
        return startLine + getLineByOffset(offset - startOffset, length: 0).0 - 1
    }
}

extension Array {
    func part(from a: Int, to b: Int) -> Array<Element> {
        return Array(self[a ..< b])
    }
}

//MARK: ExtendedComponent extensions

extension ExtendedComponent {
    var isElseIfOrIf: Bool { return self.type == .If || self.type == .ElseIf }
    var children: Int { return self.components.count }
    var containsClosure: Bool {
        return self.components.filter(){ $0.type == ComponentType.Closure }.count > 0
    }
    var containsParameter: Bool {
        return self.components.filter(){ $0.type == ComponentType.Parameter }.count > 0
    }
    var isVariableWithChildren: Bool {
        return self.type == .Variable && self.components.count > 0
    }
    var hasNoChildrenExceptELComment: Bool {
        return self.components.filter() { !$0.type.isComment && !$0.type.isEmptyLine }.count > 0 && self.type == .Variable
    }
    var isActuallyClosure: Bool {
        return self.children == 1 && self.containsClosure
    }
    var isFirstComponentBrace: Bool {
        guard self.components.count > 0 else {
            return false
        }
        return self.components[0].type == .Brace
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
}

extension ExtendedComponent : Hashable {
    var hashValue: Int {
        return components.reduce(offsetRange.start.hashValue + offsetRange.end.hashValue + type.hashValue) { $0 + $1.hashValue }
    }
}

extension ExtendedComponent : Equatable {}
func ==(lhs: ExtendedComponent, rhs: ExtendedComponent) -> Bool {
    if !(lhs.offsetRange == rhs.offsetRange) { return false }
    if lhs.type != rhs.type { return false }
    if !(Set(lhs.components) == Set(rhs.components)) { return false }
    
    return true
}

func ==(lhs: OffsetRange, rhs: OffsetRange) -> Bool {
    if lhs.end == rhs.end && lhs.start == rhs.start { return true }
    return false
}

//MARK: Linear function on double x

extension Double {
    func linearFunction(slope slope: Double, intercept: Double) -> Double {
        return slope * self + intercept
    }
    var intValue: Int {
        return Int(self)
    }
}

//MARK: Operators overloading

func *(left: String, right: Int) -> String {
    var result = ""
    for _ in 0..<right {
        result += left
    }
    return result
}
