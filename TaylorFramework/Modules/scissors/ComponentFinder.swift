//
//  ComponentFinder.swift
//  Scissors
//
//  Created by Alex Culeva on 10/2/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct ComponentFinder {
    
    let text: String
    let syntaxMap: SyntaxMap
    
    init(text: String, syntaxMap: SyntaxMap = SyntaxMap(tokens: [])) {
        self.text = text
        self.syntaxMap = syntaxMap
    }
    
    func findRanges(pattern: String, text: String) -> [OffsetRange] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.DotMatchesLineSeparators])
            return regex.matchesInString(text, options: [], range: NSMakeRange(0, text.characters.count)).map {
                $0.range
                }.reduce([OffsetRange]()) {
                    $0 + OffsetRange(start: $1.location, end: $1.location + $1.length)
            }
        } catch { return [] }
        
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
        return syntaxMap.tokens.filter {
            ComponentType(type: $0.type) == ComponentType.Comment
            }.reduce([ExtendedComponent]()) {
                $0 + ExtendedComponent(dict: $1.dictionaryValue)
        }
    }
    
    func findEmptyLines() -> [ExtendedComponent] {
        return findRanges("(\\n[ \\t\\n]*\\n)", text: text).reduce([ExtendedComponent]()) {
            let correctEmptyRange = OffsetRange(start: $1.start + 1, end: $1.end - 1)
            return $0 + ExtendedComponent(type: .EmptyLines, range: correctEmptyRange)
        }
    }
    
    //Ending points of getters and setters will most probably be wrong unless a nice coding-style is being used "} set {"
    func findGetters(components: [ExtendedComponent]) -> [ExtendedComponent] {
        return components.filter() { $0.type == .Variable }.reduce([ExtendedComponent]()) { components, component in
            let range = NSMakeRange(component.offsetRange.start, component.offsetRange.end - component.offsetRange.start)
            return findGetterAndSetter((text as NSString).substringWithRange(range)).reduce(components) {
                $1.offsetRange.start += component.offsetRange.start
                $1.offsetRange.end += component.offsetRange.start
                return $0 + $1
            }
        }
    }
    
    func findGetterAndSetter(text: String) -> [ExtendedComponent] {
        var accessors = [ExtendedComponent]()
        let gettersRanges = findRanges("(get($|[ \\t\\n{}]))", text: text)
        let settersRanges = findRanges("(set($|[ \\t\\n{}]))", text: text)
        if gettersRanges.isEmpty { return findObserverGetters(text) }
        
        accessors.append(ExtendedComponent(type: .Function, range: gettersRanges.first!, name: "get"))
        if !settersRanges.isEmpty {
            accessors.append(ExtendedComponent(type: .Function, range: settersRanges.first!, name: "set"))
        }
        accessors.sortInPlace( { $0.offsetRange.start < $1.offsetRange.start } )
        if accessors.count == 1 {
            accessors.first!.offsetRange.end = text.characters.count - 1
        } else {
            accessors.first!.offsetRange.end = accessors.second!.offsetRange.start - 1
            accessors.second!.offsetRange.end = text.characters.count - 1
        }
        
        return accessors
    }
    
    func findObserverGetters(text:String) -> [ExtendedComponent] {
        var willSetRanges = findRanges("(willSet($|[ \\t\\n{}]))", text: text)
        var didSetRanges = findRanges("(didSet($|[ \\t\\n{}]))", text: text)
        var observers = [ExtendedComponent]()
        if willSetRanges.count > 0 {
            observers.append(ExtendedComponent(type: .Function, range: willSetRanges[0], name: "willSet"))
        }
        if didSetRanges.count > 0 {
            observers.append(ExtendedComponent(type: .Function, range: didSetRanges[0], name: "didSet"))
        }
        observers.sortInPlace { $0.offsetRange.start < $1.offsetRange.start }
        if observers.count == 1 {
            observers[0].offsetRange.end = text.characters.count - 1
        } else if observers.count == 2 {
            observers[0].offsetRange.end = observers[1].offsetRange.start - 1
            observers[1].offsetRange.end = text.characters.count - 1
        }
        
        return observers
    }
    
}