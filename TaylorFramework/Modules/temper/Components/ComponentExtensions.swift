//
//  ComponentExtensions.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

protocol Serialization {
    func serialize() -> [String:AnyObject]
}

protocol Deserialization {
    associatedtype `Type`
    static func deserialize(_ dictionary: [String:AnyObject]) -> Type?
}

extension ComponentRange : Serialization, Deserialization {
    typealias `Type` = ComponentRange
    
    func serialize() -> [String:AnyObject] {
        return ["startLine" : startLine as AnyObject, "endLine" : endLine as AnyObject]
    }
    
    static func deserialize(_ dictionary: [String:AnyObject]) -> ComponentRange? {
        guard let startLine = dictionary["startLine"] as? Int else {
            return nil
        }
        guard let endLine = dictionary["endLine"] as? Int else {
            return nil
        }
        
        return ComponentRange(sl: startLine, el: endLine)
    }
}

extension ComponentRange {
    
    /**
        This property return the length of the component
    */
    
    var length: Int {
        return endLine - startLine
    }
    
    /**
        This method convert the range to xml nodes
    
        :returns: [NSXMLNode] An array with 2 objects: the begin line node and the end line node
    */
    
    func XMLAttributes() -> [XMLNode] {
        guard let beginLineNode = (XMLNode.attribute(withName: "beginline", stringValue: String(startLine)) as? XMLNode) else {
            return []
        }
        guard let endLineNode = (XMLNode.attribute(withName: "endline", stringValue: String(endLine)) as? XMLNode) else {
            return [beginLineNode]
        }
        
        return [beginLineNode, endLineNode]
    }
}

/**
    This function appends a dictionary to another

    This method accepts a dictionary of any key and value type. If in the left dictionary there are a value for same key, the value will be updated

    :param: left The dictionary with destination keys and values

    :param: right The dictionary with source keys and values
*/

func +=<KeyType, KeyValue>(left: inout Dictionary<KeyType, KeyValue>, right: Dictionary<KeyType, KeyValue>) {
    for (key, value) in right {
        left.updateValue(value, forKey: key)
    }
}

extension Component {
    
    var isRedundantLine: Bool {
        return type.isA(.comment) || type.isA(.emptyLines)
    }
    
    /**
        This property return true if the component is Class, Struct, Enum or Extension type
    
        :returns: Bool true if is construct type
    */
    
    var isConstructType: Bool {
        return type.isA(.class) || type.isA(.struct) || type.isA(.enum) || type.isA(.extension)
    }
    
    /**
        This method find recursively the parent component of Class type
        
        If there are no parent component of Class type, the method will return nil
    
        :returns: Component? The parent component of Class type
    */
    
    func classComponent() -> Component? {
        if isConstructType { return self }
        guard let parentComponent = parent else {
            return nil
        }
        
        return parentComponent.classComponent()
    }
    
    /**
        This method find the next component from components array
        
        If the component is the last in the array, the method will return nil
        
        :returns: Component? The next component
    */
    
    func nextComponent() -> Component? {
        guard let parent = parent else {
            return nil
        }
        let components = parent.components
        for (index, value) in components.enumerated() {
            if value === self && index < components.count - 1 {
                return components[index + 1]
            }
        }
        return nil
    }
}
