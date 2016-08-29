//
//  PMDCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

final class PMDCoordinator: WritingCoordinator {
    
    func writeViolations(violations: [Violation], atPath path: String) {
        NSFileManager().removeFileAtPath(path)
        let xml = generateXML(violations)
        let xmlData = xml.XMLDataWithOptions(NSXMLNodePrettyPrint)
        do {
            try xmlData.writeToFile(path, options: NSDataWritingOptions.DataWritingWithoutOverwriting)
        } catch {
            print("Error while writing the XML object to file.")
        }
    }
    
    private func generateXML(violations: [Violation]) -> NSXMLDocument {
        let xml = NSXMLDocument(rootElement: NSXMLElement(name: "pmd"))
        xml.version = "1.0"
        xml.characterEncoding = "UTF-8"
        addElementsToXML(xml, fromViolations: violations)
        return xml
    }
    
    private func addElementsToXML(xml: NSXMLDocument, fromViolations violations: [Violation]) {
        for filePath in filePathsFromViolations(violations) {
            let fileElement = NSXMLElement(name: "file")
            let attributeNode = NSXMLNode.attributeWithName("name", stringValue: filePath) as? NSXMLNode
            guard let attribute = attributeNode else {
                return
            }
            fileElement.addAttribute(attribute)
            let _ = violations.filter({ $0.path == filePath }).map({ fileElement.addChild($0.toXMLElement()) })
            if let root = xml.rootElement() {
                root.addChild(fileElement)
            }
        }
    }
    
    private func filePathsFromViolations(violations: [Violation]) -> [String] {
        return violations.map({ $0.path }).unique
    }
}
