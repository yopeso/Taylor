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
    var bodyRange: OffsetRange?
    var type: ComponentType
    var names: Names
    var parent: ExtendedComponent?
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
    
    init(type: ComponentType, range: OffsetRange, bodyRange: OffsetRange? = nil, names: Names = (nil, nil)) {
        self.type = type
        self.bodyRange = bodyRange
        self.offsetRange = range
        self.components = []
        self.names = names
    }
    
    init(dict: [String: AnyObject]) {
        self.type = (dict["type"] as? String).flatMap(ComponentType.init) ?? .other
        self.offsetRange = {
            guard let start = dict["offset"] as? Int, let length = dict["length"] as? Int else {
                return .zero
            }
            return OffsetRange(start: start, end: start + length - 1)
        }()
        self.bodyRange = {
            guard let start = dict["bodyoffset"] as? Int, let length = dict["bodylength"] as? Int else {
                return .zero
            }
            return OffsetRange(start: start, end: start + length - 1)
        }()
        self.names = (nil, nil)
        self.components = []
    }
    
    func appendComponents(_ array: [SourceKitRepresentable], components: NSMutableArray = []) -> [ExtendedComponent] {
        var braces = 0
        array.enumerated().forEach { childIndex, structure in
            let hashedStructure = structure.dictionaryValue
            var offsetRange = hashedStructure.offsetRange
            let bodyOffsetRange = hashedStructure.bodyRange
            let type = getComponentType(hashedStructure.type, bracesCount: braces, isLast: childIndex == array.count - 1)
            if type.isA(.other) { return }
            if type.isA(.brace) { braces += 1 }
            if type.isA(.variable) {
                let bodyOffsetEnd = hashedStructure.bodyLength + hashedStructure.bodyOffset
                if bodyOffsetEnd != 0 { offsetRange.end = bodyOffsetEnd }
            }
            let child = ExtendedComponent(type: type, range: offsetRange, bodyRange: bodyOffsetRange,
                                          names: (hashedStructure.name, hashedStructure.typeName))
            components.add(child)
            _ = child.appendComponents(hashedStructure.substructure, components: components)
        }
        
        // Safe to unwrap, all objects are `ExtendedComponent`
        return components as NSArray as! [ExtendedComponent]
    }
    
    func getComponentType(_ type: String, bracesCount: Int, isLast: Bool) -> ComponentType {
        let type = ComponentType(rawValue: type)
        if isElseIf(type) {
            return .elseIf
        }
        if isElse(type) && isLast && bracesCount > 0 {
            return .else
        }
        return type
    }
    
    func variablesToFunctions() {
        forEach { component in
            guard component.hasSignificantChildren && component.isA(.variable) else {
                if component.isA(.brace) && component.containsParameter {
                    component.type = .closure
                }
                return
            }
            component.type = .function
            if let firstChild = component.components.first , component.isActuallyClosure {
                firstChild.name = component.name
                component.parent?.components.append(firstChild)
                component.parent?.remove(component)
            }
        }
    }
    
    func filter(_ types: [ComponentType]) {
        forEach {
            $0.components = $0.components.filter { component in
                for type in types { if component.isA(type) { return false } }
                return true
            }
        }
    }
    
    func processBracedType() {
        if children > 1 {
            changeChildToParent(1)
        }
        self.takeChildrenOfChild(0)
        if type != .repeat {
            offsetRange.end = components[0].offsetRange.end
        }
        components.remove(at: 0)
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
            if component.type.isBraced {
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
        forEach { $0.parent?.components.sort { $0.offsetRange < $1.offsetRange } }
    }
}
