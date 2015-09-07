//
//  Component.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

public enum ComponentType {
    case Class
    case Function
    case Comment
    case EmptyLines
    case Struct
    case Enum
    case If
    case Else
    case For
    case Do
    case Catch
    case While
    case Switch
    case Case
}

public struct Component {
    public let type: ComponentType
    public let range: ComponentRange
    public var name: String?
    public let components: [Component]
    
    public init(type:ComponentType, range: ComponentRange, components:[Component], name: String) {
        self.type = type
        self.range = range
        self.components = components
        self.name = name
    }
    
    public init(type:ComponentType, range: ComponentRange, components:[Component]) {
        self.type = type
        self.range = range
        self.components = components
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
