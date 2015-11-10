//
//  Tree.swift
//  Scissors
//
//  Created by Alex Culeva on 9/14/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SwiftXPC
import SourceKittenFramework

final class Tree {
    let file: File
    let dictionary: XPCDictionary
    let syntaxMap: SyntaxMap
    let parts: [File]
    
    init(file: File) {
        let structure = Structure(file: file)
        self.file = file
        dictionary = structure.dictionary
        syntaxMap = structure.syntaxMap
        self.parts = file.divideByLines()
    }
    
    //MARK: Dictionary to tree methods
    
    func makeTree() -> Component {
        let root = ExtendedComponent(type: .Other, range: dictionary.offsetRange)
        let noStringsText = replaceStringsWithSpaces(parts.map() { $0.contents })
        
        let finder = ComponentFinder(text: noStringsText, syntaxMap: syntaxMap)
        var componentsArray = root.appendComponents([], array: dictionary.substructure)
        componentsArray += finder.findGetters(componentsArray)
        arrayToTree(componentsArray, root: root)
        root.removeRedundantClosures()
        processBraces(root)
        arrayToTree(additionalComponents(finder), root: root)
        root.variablesToFunctions()
        sortTree(root)
        
        return convertTree(root)
    }
    
    func additionalComponents(finder: ComponentFinder) -> [ExtendedComponent] {
        return finder.findComments() + finder.findLogicalOperators() + finder.findEmptyLines()
    }
    
    //MARK: Conversion to Component type
    
    func convertTree(root: ExtendedComponent) -> Component {
        let rootComponent = Component(type: root.type, range: ComponentRange(sl: 1, el: file.lines.count))
        convertToComponent(root, componentNode: rootComponent)
        
        return rootComponent
    }
    
    func convertToComponent(node: ExtendedComponent, componentNode: Component) {
        for component in node.components {
            let child = componentNode.makeComponent(type: component.type,
                range: offsetToLine(component.offsetRange))
            child.name = component.name
            convertToComponent(component, componentNode: child)
        }
    }
    
    func offsetToLine(offsetRange: OffsetRange) -> ComponentRange {
        
        let startIndex = parts.filter() { $0.startOffset <= offsetRange.start }.count - 1
        let endIndex = parts.filter() { $0.startOffset <= offsetRange.end }.count - 1
    
        
        return ComponentRange(sl: parts[startIndex].getLineRange(offsetRange.start), el: parts[endIndex].getLineRange(offsetRange.end))
    }
    
    func arrayToTree(components: [ExtendedComponent], root: ExtendedComponent) -> ExtendedComponent {
        let parent = root
        parent.insert(components)
        
        return parent
    }
    
    //MARK: Processing the tree
    
    func processBraces(parent: ExtendedComponent) {
        var i = 0
        while i < parent.components.count {
            let component = parent.components[i]; i++
            let type = component.type
            let bracedTypes = [ComponentType.If, .ElseIf, .For, .While, .Repeat, .Closure]
            if bracedTypes.contains(type)  {
                guard component.isFirstComponentBrace else {
                    continue
                }
                component.processBracedType()
            }
            processBraces(component)
        }
    }
    
    func sortTree(root: ExtendedComponent) {
        for component in root.components {
            sortTree(component)
            component.sortChildren()
        }
    }
    
    //MARK: Text filtering methods
    
    func replaceStringsWithSpaces(text: [String]) -> String {
        var noStrings = ""
        for var part in text {
            if part.isEmpty { continue }
            for string in re.findall("\\\".*?\\\"", part, flags: [NSRegularExpressionOptions.DotMatchesLineSeparators]) {
                let len = string.characters.count
                part = part.stringByReplacingOccurrencesOfString(string, withString: " " * len)
            }
            noStrings += part + "\n"
        }
        return noStrings
    }
}
