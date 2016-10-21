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
    
    /**
     Finds all comments, logical operators (`??`, `? :`, `&&`, `||`) and
     empty lines in **text**.
     */
    var additionalComponents: [ExtendedComponent] {
        return findComments() + findLogicalOperators() + findEmptyLines()
    }
    
    func findLogicalOperators() -> [ExtendedComponent] {
        var operators = findOROperators()
        operators.append(contentsOf: findANDOperators())
        operators.append(contentsOf: findTernaryOperators())
        operators.append(contentsOf: findNilCoalescingOperators())
        
        return operators
    }
    
    func findOROperators() -> [ExtendedComponent] {
        return text.findMatchRanges("(\\|\\|)").map {
            ExtendedComponent(type: .or, range: $0)
        }
    }
    
    func findANDOperators() -> [ExtendedComponent] {
        return text.findMatchRanges("(\\&\\&)").map {
            ExtendedComponent(type: .and, range: $0)
        }
    }
    
    func findTernaryOperators() -> [ExtendedComponent] {
        return text.findMatchRanges("(\\s+\\?(?!\\?).*?:)").map {
            ExtendedComponent(type: .ternary, range: $0)
        }
    }
    
    func findNilCoalescingOperators() -> [ExtendedComponent] {
        return text.findMatchRanges("(\\?\\?)").map {
            ExtendedComponent(type: .nilCoalescing, range: $0)
        }
    }
    
    func findComments() -> [ExtendedComponent] {
        return syntaxMap.tokens.filter {
            componentTypeUIDs[$0.type] == .comment
            }.reduce([ExtendedComponent]()) {
                $0 + ExtendedComponent(dict: $1.dictionaryValue as [String : AnyObject])
        }
    }
    
    func findEmptyLines() -> [ExtendedComponent] {
        return text.findMatchRanges("(\\n[ \\t\\n]*\\n)").map {
            return ExtendedComponent(type: .emptyLines, range: ($0 as OffsetRange).toEmptyLineRange())
        }
    }
    
    //Ending points of getters and setters will most probably be wrong unless a nice coding-style is being used "} set {"
    func findGetters(_ components: [ExtendedComponent]) -> [ExtendedComponent] {
        return components.filter({ $0.type.isA(.variable) })
            .reduce([ExtendedComponent]()) { reduceFindGetterAndSetter(components: $0, component: $1) }
    }
    
    func reduceFindGetterAndSetter(components: [ExtendedComponent],
                                   component: ExtendedComponent) -> [ExtendedComponent] {
        let range: Range = component.offsetRange.start..<component.offsetRange.end
        
        return findGetterAndSetter(text.substring(with: range)).reduce(components) {
            $1.offsetRange.start += component.offsetRange.start
            $1.offsetRange.end += component.offsetRange.start
            return $0 + $1
        }
    }
    
    func findGetterAndSetter(_ text: String) -> [ExtendedComponent] {
        var accessors = [ExtendedComponent]()
        guard let _ : OffsetRange = text.findMatchRanges("(get($|[ \\t\\n{}]))").first else {
            return findObserverGetters(text)
        }
        
        accessors.addIfFind(component: .get, from: text)
        accessors.addIfFind(component: .set, from: text)
        
        return accessors.changeSortedOffset(of: text)
    }
    
    func findObserverGetters(_ text: String) -> [ExtendedComponent] {
        var observers = [ExtendedComponent]()
        
        observers.addIfFind(component: .willSet, from: text)
        observers.addIfFind(component: .didSet, from: text)
        
        return observers.changeSortedOffset(of: text)
    }
    
}

private extension Array where Element: ExtendedComponent {
    mutating func addIfFind(component: PropertyComponents, from text: String) {
        let range: [OffsetRange] = text.findMatchRanges("(\(component.rawValue)($|[ \\t\\n{}]))")
        
        if let first = range.first {
            append(Element(type: .function, range: first, names: (component.rawValue, nil)))
        }
    }
    
    mutating func changeSortedOffset(of text: String) -> [ExtendedComponent] {
        sort { $0.offsetRange.start < $1.offsetRange.start }
        if count == 1 {
            first?.offsetRange.end = text.characters.count - 1
        } else if let second = second {
            first?.offsetRange.end = second.offsetRange.start - 1
            second.offsetRange.end = text.characters.count - 1
        }
        
        return self
    }
}

