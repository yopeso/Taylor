//
//  PMDCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

final class PMDCoordinator: WritingCoordinator {
    
    func writeViolations(_ violations: [Violation], atPath path: String) {
        FileManager().removeFileAtPath(path)
        let xml = generateXML(violations)
        let xmlData = xml.xmlData(withOptions: Int(XMLNode.Options.nodePrettyPrint.rawValue))
        do {
            try xmlData.write(to: URL(fileURLWithPath: path), options: NSData.WritingOptions.withoutOverwriting)
        } catch {
            print("Error while writing the XML object to file.")
        }
    }
    
    fileprivate func generateXML(_ violations: [Violation]) -> XMLDocument {
        let xml = XMLDocument(rootElement: XMLElement(name: "pmd"))
        xml.version = "1.0"
        xml.characterEncoding = "UTF-8"
        addElementsToXML(xml, fromViolations: violations)
        return xml
    }
    
    fileprivate func addElementsToXML(_ xml: XMLDocument, fromViolations violations: [Violation]) {
        for filePath in filePathsFromViolations(violations) {
            let fileElement = XMLElement(name: "file")
            let attributeNode = XMLNode.attribute(withName: "name", stringValue: filePath) as? XMLNode
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
    
    fileprivate func filePathsFromViolations(_ violations: [Violation]) -> [String] {
        return violations.map({ $0.path }).unique
    }
}
