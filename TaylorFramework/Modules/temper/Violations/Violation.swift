//
//  Violation.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

class Violation {
    var path : String
    let component : Component
    let rule : Rule
    let message : String
    let value : Int
    init(component: Component, rule: Rule, message: String, path: String, value: Int) {
        self.component = component
        self.rule = rule
        self.message = message
        self.value = value
        self.path = path.stringByReplacingOccurrencesOfString("\\", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func toDictionary() -> Dictionary<String, AnyObject> {
        var violationDictionary = Dictionary<String, AnyObject>()
        violationDictionary["path"] = path
        violationDictionary["rule"] = rule.rule
        violationDictionary["message"] = message
        violationDictionary["priority"] = rule.priority
        if let classComponent = component.classComponent() {
            if let name = classComponent.name {
                violationDictionary["class"] = name
            }
        }
        if component.type == .Function {
            violationDictionary["method"] = component.name
        }
        violationDictionary["value"] = value
        violationDictionary["externalInfoUrl"] = rule.externalInfoUrl
        violationDictionary += component.range.serialize()
        return violationDictionary
    }
    
    private func XMLNodes() -> [NSXMLNode] {
        var attributes = component.range.XMLAttributes()
        attributes = addNodeWithName("rule", stringValue: rule.rule, toAttributes: attributes)
        if let classComponent = component.classComponent() {
            if let name = classComponent.name {
                attributes = addNodeWithName("class", stringValue: name, toAttributes: attributes)
            }
        }
        if component.type == ComponentType.Function {
            if let name = component.name {
                attributes = addNodeWithName("method", stringValue: name, toAttributes: attributes)
            }
        }
        attributes = addNodeWithName("value", stringValue: String(value), toAttributes: attributes)
        attributes = addNodeWithName("externalInfoUrl", stringValue: rule.externalInfoUrl, toAttributes: attributes)
        attributes = addNodeWithName("priority", stringValue: String(rule.priority), toAttributes: attributes)
        
        return attributes
    }
    
    private func addNodeWithName(name: String, stringValue: String, toAttributes attributes: [NSXMLNode]) -> [NSXMLNode] {
        var newArray = attributes
        if let node = NSXMLNode.attributeWithName(name, stringValue: stringValue) as? NSXMLNode {
            newArray.append(node)
            return newArray
        }
        
        return attributes
    }
    
    func toXMLElement() -> NSXMLElement {
        let violationElement = NSXMLElement(name: "violation", stringValue: message)
        let violationAttributes = XMLNodes()
        for attribute in violationAttributes {
            violationElement.addAttribute(attribute)
        }
        return violationElement
    }
    
    var errorString : String {
        return "\(path):\(component.range.startLine):0: warning: \(rule.rule)(P\(rule.priority)):\(message)\n"
    }
    
    var toString : String {
        return path + ":" + String(component.range.startLine) + ":" + rule.rule + " P" + String(rule.priority) + " " + message + "\n"
    }
}