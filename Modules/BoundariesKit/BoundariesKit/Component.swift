//
//  Component.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

public enum ComponentType {
    case Class
    case Struct
    case Enum
    case Protocol
    case Function
    case Parameter
    case Comment
    case EmptyLines
    case Repeat
    case While
    case If
    case Else
    case Do
    case Catch
    case For
    case Switch
    case Case
    
    case Other
}

public class Component {
    public var parent: Component?
    public let type: ComponentType
    public let range: ComponentRange
    public var name: String?
    public var components = [Component]()
    
    public init(type: ComponentType, range: ComponentRange, name: String? = nil) {
        self.type = type
        self.range = range
        self.name = name
    }
    
    public func makeComponent(type type: ComponentType, range: ComponentRange, name: String? = nil) -> Component {
        let component = Component(type: type, range: range, name: name)
        
        component.parent = self
        self.components.append(component)
        
        return component
    }
}

extension Component : Equatable {}

public func ==(lhs: Component, rhs: Component) -> Bool {
    if lhs.range != rhs.range { return false }
    if lhs.type != rhs.type { return false }
    if lhs.name !~== lhs.name { return false }
    if rhs.components != lhs.components { return false }
    
    return true
}
