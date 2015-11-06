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

final class Finder {
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