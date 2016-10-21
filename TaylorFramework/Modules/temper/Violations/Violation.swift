//
//  Violation.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

struct ViolationData {
    let message: String
    let path: String
    let value: Int
    init(message: String, path: String, value: Int) {
        self.message = message
        self.path = path
        self.value = value
    }
}

struct Violation {
    
    var path: String
    let component: Component
    let rule: Rule
    let message: String
    let value: Int
    
    init(component: Component, rule: Rule, violationData: ViolationData) {
        self.component = component
        self.rule = rule
        self.message = violationData.message
        self.value = violationData.value
        self.path = violationData.path.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
    
    func toDictionary() -> Dictionary<String, AnyObject> {
        var violationDictionary = Dictionary<String, AnyObject>()
        violationDictionary["path"] = path as AnyObject?
        violationDictionary["rule"] = rule.rule as AnyObject?
        violationDictionary["message"] = message as AnyObject?
        violationDictionary["priority"] = rule.priority as AnyObject?
        if let classComponent = component.classComponent() {
            if let name = classComponent.name {
                violationDictionary["class"] = name as AnyObject?
            }
        }
        if component.type == .function {
            violationDictionary["method"] = component.name as AnyObject?
        }
        violationDictionary["value"] = value as AnyObject?
        violationDictionary["externalInfoUrl"] = rule.externalInfoUrl as AnyObject?
        violationDictionary += component.range.serialize()
        return violationDictionary
    }
    
    fileprivate func XMLNodes() -> [XMLNode] {
        var attributes = component.range.XMLAttributes()
        attributes = addNodeWithName("rule", stringValue: rule.rule, toAttributes: attributes)
        if let classComponent = component.classComponent() {
            if let name = classComponent.name {
                attributes = addNodeWithName("class", stringValue: name, toAttributes: attributes)
            }
        }
        if component.type == ComponentType.function {
            if let name = component.name {
                attributes = addNodeWithName("method", stringValue: name, toAttributes: attributes)
            }
        }
        attributes = addNodeWithName("value", stringValue: String(value), toAttributes: attributes)
        attributes = addNodeWithName("externalInfoUrl", stringValue: rule.externalInfoUrl, toAttributes: attributes)
        attributes = addNodeWithName("priority", stringValue: String(rule.priority), toAttributes: attributes)
        
        return attributes
    }
    
    fileprivate func addNodeWithName(_ name: String, stringValue: String, toAttributes attributes: [XMLNode]) -> [XMLNode] {
        var newArray = attributes
        if let node = XMLNode.attribute(withName: name, stringValue: stringValue) as? XMLNode {
            newArray.append(node)
            return newArray
        }
        
        return attributes
    }
    
    func toXMLElement() -> XMLElement {
        let violationElement = XMLElement(name: "violation", stringValue: message)
        return XMLNodes().reduce(violationElement) {
            $0.addAttribute($1)
            return $0
        }
    }
    
    var errorString: String {
        return "\(path):\(component.range.startLine):0: warning: \(rule.rule)(P\(rule.priority)):\(message)\n"
    }
    
    var toString: String {
        return path + ":" + String(component.range.startLine) + ":" + rule.rule + " P" + String(rule.priority) + " " + message + "\n"
    }
}
