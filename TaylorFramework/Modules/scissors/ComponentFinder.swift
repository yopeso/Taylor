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
    
    func findLogicalOperators() -> [ExtendedComponent] {
        let boolOperators =
            text.findMatchRanges("(\\|\\|)").map { ExtendedComponent(type: .Or, range: $0) } +
            text.findMatchRanges("(\\&\\&)").map { ExtendedComponent(type: .And, range: $0) }
        return text.findMatchRanges("(\\s+\\?(?!\\?).*?:)").map {
                ExtendedComponent(type: .Ternary, range: $0)
            } + text.findMatchRanges("(\\?\\?)").map {
                ExtendedComponent(type: .NilCoalescing, range: $0)
        } + boolOperators
    }
    
    func findComments() -> [ExtendedComponent] {
        return syntaxMap.tokens.filter {
                types[$0.type] == .Comment
            }.reduce([ExtendedComponent]()) {
                $0 + ExtendedComponent(dict: $1.dictionaryValue)
        }
    }
    
    func findEmptyLines() -> [ExtendedComponent] {
        return text.findMatchRanges("(\\n[ \\t\\n]*\\n)").map {
            return ExtendedComponent(type: .EmptyLines, range: ($0 as OffsetRange).toEmptyLineRange())
        }
    }
    
    //Ending points of getters and setters will most probably be wrong unless a nice coding-style is being used "} set {"
    func findGetters(components: [ExtendedComponent]) -> [ExtendedComponent] {
        return components.filter { ($0 as ExtendedComponent).type == .Variable }.reduce([ExtendedComponent]()) { components, component in
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
        let gettersRanges: [OffsetRange] = text.findMatchRanges("(get($|[ \\t\\n{}]))")
        let settersRanges: [OffsetRange] = text.findMatchRanges("(set($|[ \\t\\n{}]))")
        if gettersRanges.isEmpty { return findObserverGetters(text) }
        
        accessors.append(ExtendedComponent(type: .Function, range: gettersRanges.first!, names: ("get", nil)))
        if !settersRanges.isEmpty {
            accessors.append(ExtendedComponent(type: .Function, range: settersRanges.first!, names: ("set", nil)))
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
        var willSetRanges: [OffsetRange] = text.findMatchRanges("(willSet($|[ \\t\\n{}]))")
        var didSetRanges: [OffsetRange] = text.findMatchRanges("(didSet($|[ \\t\\n{}]))")
        var observers = [ExtendedComponent]()
        if willSetRanges.count > 0 {
            observers.append(ExtendedComponent(type: .Function, range: willSetRanges[0], names: ("willSet", nil)))
        }
        if didSetRanges.count > 0 {
            observers.append(ExtendedComponent(type: .Function, range: didSetRanges[0], names: ("didSet", nil)))
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