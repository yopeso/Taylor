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
                self.type = ComponentType(type: type)
                self.offsetRange = OffsetRange(start: startOffset, end: endOffset - 1)
        } else {
            self.type = .Other
            self.offsetRange = OffsetRange(start: 0, end: 0)
        }
        self.names = (nil, nil)
        self.components = []
    }
    
    func appendComponents(var components: [ExtendedComponent], array: XPCArray) -> [ExtendedComponent] {
        var braces = 0
        array.enumerate().forEach { (childNumber, structure) in
            var offsetRange = structure.asDictionary.offsetRange
            let type = getComponentType(structure.asDictionary.type, bracesCount: braces, isLast: childNumber == array.count - 1)
            if type.isVariable {
                let bodyOffsetEnd = structure.asDictionary.bodyLength + structure.asDictionary.bodyOffset
                if bodyOffsetEnd != 0 { offsetRange.end = bodyOffsetEnd }
            } else if type.isOther { return }
            if type.isBrace { braces++ }
            let child = ExtendedComponent(type: type, range: offsetRange, names: (structure.asDictionary.name, structure.asDictionary.typeName))
            components.append(child)
            components = child.appendComponents(components, array: structure.asDictionary.substructure)
        }
        
        return components
    }
    
    func getComponentType(type: String, bracesCount: Int, isLast: Bool) -> ComponentType {
        let type = ComponentType(type: type)
        if isElseIf(type) { return .ElseIf }
        else if isElse(type) && isLast && bracesCount > 0 { return .Else }
        else { return type }
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
            !($0.type == .Closure && $0.components.isEmpty)
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