//
//  Tree.swift
//  Scissors
//
//  Created by Alex Culeva on 9/14/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct Tree {
    let file: File
    let dictionary: [String: SourceKitRepresentable]
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
        let root = ExtendedComponent(type: .Other, range: dictionary.offsetRange, names: (nil, nil))
        let noStringsText = replaceStringsWithSpaces(parts.map() { $0.contents })
        let finder = ComponentFinder(text: noStringsText, syntaxMap: syntaxMap)
        let sourcekitComponents = root.appendComponents(dictionary.substructure)
                
        root.insert(sourcekitComponents + finder.findGetters(sourcekitComponents))
        root.removeRedundantClosures()
        root.processBraces()
        root.insert(finder.additionalComponents)
        root.process()
        root.filter([.Array, .Dictionary, .Object, .EnumElement])
        
        return convertTree(root)
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
    
    //MARK: Text filtering methods
    
    func replaceStringsWithSpaces(text: [String]) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "\\\".*?\\\"", options: [.DotMatchesLineSeparators])
            return text.filter { !$0.isEmpty }.reduce("") {
                let matchRanges = regex.matchesInString($1, options: [], range: NSMakeRange(0, $1.characters.count)).map { $0.range }
                return $0 + ($1 as NSString).stringByReplacingCharactersInRangesWithSpaces(matchRanges) + "\n"
            }
        } catch { return "" }
    }
}

extension NSString {
    func stringByReplacingCharactersInRangesWithSpaces(ranges: [NSRange]) -> String {
        var string = self
        ranges.forEach { string = string.stringByReplacingCharactersInRange($0, withString: " " * $0.length) }
        return string as String
    }
}
