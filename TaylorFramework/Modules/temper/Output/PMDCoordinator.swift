//
//  PMDCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

private typealias ViolationsMap = [Path: [Violation]]

final class PMDCoordinator: WritingCoordinator {
    
    func writeViolations(_ violations: [Violation], atPath path: String) {
        FileManager().removeFileAtPath(path)
        let map = mapViolations(violations)
        let xml = generateXML(from: map)
        let xmlData = xml.xmlData(options: .nodePrettyPrint)
        do {
            try xmlData.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch let error {
            let message = "Error while creating PMD report." + "\n" +
                          "Reason: " + error.localizedDescription
            Printer(verbosityLevel: .error).printError(message)
        }
    }
    
    private func mapViolations(_ violations: [Violation]) -> ViolationsMap {
        return violations.reduce([Path : [Violation]]()) { result, violation in
            let path = violation.path
            
            // Add violation to the group with the same path
            var violations = result[path] ?? []
            violations.append(violation)
            
            // Update the result
            var nextResult = result
            nextResult[path] = violations
            
            return nextResult
        }
    }
    
    private func generateXML(from violationsMap: ViolationsMap) -> XMLDocument {
        let xml = XMLDocument(rootElement: XMLElement(name: "pmd"))
        xml.version = "1.0"
        xml.characterEncoding = "UTF-8"
        
        let fileElements = violationsMap.map(generateFileElement)
        xml.rootElement()?.addChildren(fileElements)
        
        return xml
    }
    
    private func generateFileElement(path: Path, violations: [Violation]) -> XMLElement {
        let element = XMLElement(name: "file")
        if let attribute = XMLNode.attribute(withName: "name", stringValue: path) as? XMLNode {
            element.addAttribute(attribute)
        }
        
        violations.forEach { element.addChild($0.toXMLElement()) }
        
        return element
    }
}

extension XMLElement {
    func addChildren(_ children: [XMLElement]) {
        children.forEach(addChild)
    }
}
