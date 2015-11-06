//
//  ExtendedComponent.swift
//  Scissors
//
//  Created by Alex Culeva on 9/17/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import BoundariesKit
import SourceKittenFramework
import SwiftXPC

final class ExtendedComponent {
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