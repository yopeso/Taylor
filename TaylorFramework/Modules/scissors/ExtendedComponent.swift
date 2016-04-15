//
//  ExtendedComponent.swift
//  Scissors
//
//  Created by Alex Culeva on 9/17/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework

typealias Names = (name: String?, typeName: String?)

final class ExtendedComponent {
    
    var offsetRange: OffsetRange
    var type: ComponentType
    var names: Names
    var parent: ExtendedComponent? = nil
    var components: [ExtendedComponent]
    
    var name: String? {
        get {
            return names.name
        }
        set {
            names.name = name
        }
    }
    
    var typeName: String? {
        get {
            return names.typeName
        }
    }
    
    init(type: ComponentType, range: OffsetRange, names: Names = (nil, nil)) {
        self.type = type
        self.offsetRange = range
        self.components = []
        self.names = names
    }
    
    init(dict: [String: AnyObject]) {
        if let type = dict["type"] as? String,
            startOffset = dict["offset"] as? Int,
            length = dict["length"] as? Int {
                let endOffset = startOffset + length
                self.type = ComponentType(rawValue: type)
                self.offsetRange = OffsetRange(start: startOffset, end: endOffset - 1)
        } else {
            self.type = .Other
            self.offsetRange = OffsetRange(start: 0, end: 0)
        }
        self.names = (nil, nil)
        self.components = []
    }
    
    func appendComponents(array: [SourceKitRepresentable], components: NSMutableArray = []) -> [ExtendedComponent] {
        var braces = 0
        array.enumerate().forEach { childIndex, structure in
            let hashedStructure = structure.dictionaryValue
            var offsetRange = hashedStructure.offsetRange
            let type = getComponentType(hashedStructure.type, bracesCount: braces, isLast: childIndex == array.count - 1)
            if type.isA(.Other) { return }
            if type.isA(.Brace) { braces += 1 }
            if type.isA(.Variable) {
                let bodyOffsetEnd = hashedStructure.bodyLength + hashedStructure.bodyOffset
                if bodyOffsetEnd != 0 { offsetRange.end = bodyOffsetEnd }
            }
            let child = ExtendedComponent(type: type, range: offsetRange, names: (hashedStructure.name, hashedStructure.typeName))
            components.addObject(child)
            child.appendComponents(hashedStructure.substructure, components: components)
        }
        
        return components as AnyObject as! [ExtendedComponent] // Safe to unwrap, all objects are `ExtendedComponent`
    }
    
    func getComponentType(type: String, bracesCount: Int, isLast: Bool) -> ComponentType {
        let type = ComponentType(rawValue: type)
        if isElseIf(type) { return .ElseIf }
        else if isElse(type) && isLast && bracesCount > 0 { return .Else }
        return type
    }
    
    func variablesToFunctions() {
        forEach { component in
            guard component.hasSignificantChildren && component.isA(.Variable) else {
                if component.isA(.Brace) && component.containsParameter {
                    component.type = .Closure
                }
                return
            }
            component.type = .Function
            if let firstChild = component.components.first where component.isActuallyClosure {
                firstChild.name = component.name
                component.parent?.components.append(firstChild)
                component.parent?.remove(component)
            }
        }
    }
    
    func filter(types: [ComponentType]) {
        forEach {
            $0.components = $0.components.filter { component in
                for type in types { if component.isA(type) { return false } }
                return true
            }
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
}

extension ExtendedComponent {
    /**
        Lifts braces a level upper if their first component is a *Brace* too
        which is happening in **do**, **catch** and **repeat** blocks.
    */
    func processBraces() {
        var i = 0
        while i < components.count {
            let component = components[i]
            i += 1
            if component.type.isBraced  {
                guard component.isFirstComponentBrace else { continue }
                component.processBracedType()
            }
            component.processBraces()
        }
    }
    
    func process() {
        variablesToFunctions()
        processParameters()
        removeRedundantParameters()
        sort()
    }
    
    func sort() {
        forEach { $0.parent?.components.sortInPlace { $0.offsetRange < $1.offsetRange } }
    }
}
