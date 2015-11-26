//
//  Component.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

enum ComponentType {
    case Class
    case Struct
    case Enum
    case Protocol
    case Extension
    case Function
    case Parameter
    case Comment
    case EmptyLines
    case Repeat
    case While
    case If
    case ElseIf
    case Else
    case For
    case Switch
    case Case
    case Brace
    case And
    case Or
    case NilCoalescing
    case Ternary
    case Variable
    case Closure
    
    case Other
}

final class Component {
    var parent: Component?
    let type: ComponentType
    let range: ComponentRange
    var name: String?
    var components = [Component]()
    
    init(type: ComponentType, range: ComponentRange, name: String? = nil) {
        self.type = type
        self.range = range
        self.name = name
    }
    
    func makeComponent(type type: ComponentType, range: ComponentRange, name: String? = nil) -> Component {
        let component = Component(type: type, range: range, name: name)
        
        component.parent = self
        self.components.append(component)
        
        return component
    }
}

extension Component : Hashable {
    var hashValue: Int {
        return components.reduce(range.startLine.hashValue + range.endLine.hashValue + type.hashValue) { $0 + $1.hashValue }
    }
}

extension Component : Equatable {}

func ==(lhs: Component, rhs: Component) -> Bool {
    if lhs.range != rhs.range { return false }
    if lhs.type != rhs.type { return false }
    if lhs.name !~== lhs.name { return false }
    if !(Set(lhs.components) == Set(rhs.components)) { return false }
    
    return true
}
