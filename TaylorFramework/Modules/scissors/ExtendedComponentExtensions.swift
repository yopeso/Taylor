//
//  ExtendedComponentExtensions.swift
//  Taylor
//
//  Created by Alexandru Culeva on 4/12/16.
//  Copyright © 2016 YOPESO. All rights reserved.
//

import Foundation

extension ExtendedComponent {
    
    /**
        Recursively applies *block* over each node in tree starting
        from a level deeper.
    */
    func forEach(@noescape block: ExtendedComponent -> ()) {
        components.forEach {
            block($0)
            $0.forEach(block)
        }
    }
    
    /**
        Recursively applies *block* over each node in tree starting
        from the end of tree.
    */
    func forEachReversed(@noescape block: ExtendedComponent -> ()) {
        components.forEach { $0.forEachReversed(block) }
        block(self)
    }
    
    func isA(otherType: ComponentType) -> Bool { return self.type.isA(otherType) }
    
    var isElseIfOrIf: Bool { return isA(.If) || isA(.ElseIf) }
    var children: Int { return self.components.count }
    var containsClosure: Bool {
        return self.components.filter { $0.isA(.Closure) }.count > 0
    }
    
    var isCorrectParameter: Bool {
        guard isA(.Parameter) else { return true }
        guard name != nil else { return true }
        let startsWithDollar = name![name!.startIndex] == "$"
        
        if typeName == nil {
            return !startsWithDollar || parent!.isA(.Closure)
        } else {
            return (!startsWithDollar && name != typeName) || parent!.isA(.Closure)
        }
    }
    
    var containsParameter: Bool {
        return self.components.filter { $0.type.isA(.Parameter) }.count > 0
    }
    
    var hasSignificantChildren: Bool {
        return self.components.filter { $0.type.isSignificant }.count > 0
    }
    
    var isActuallyClosure: Bool {
        return self.children == 1 && self.containsClosure
    }
    
    var isFirstComponentBrace: Bool {
        guard self.components.count > 0 else {
            return false
        }
        return self.components[0].type == .Brace
    }
    
    func insert(components: [ExtendedComponent]) {
        components.forEach { self.insert($0) }
    }
    
    func isElseIf(type: ComponentType) -> Bool {
        return type == .If && self.isElseIfOrIf
    }
    
    func isElse(type: ComponentType) -> Bool {
        return type == .Brace && self.isElseIfOrIf
    }
    
    func changeChildToParent(index: Int) {
        parent?.addChild(components[index])
        components.removeAtIndex(index)
    }
    
    func takeChildrenOfChild(index: Int) {
        for child in components[index].components {
            addChild(child)
        }
    }
    
    func addChild(child: ExtendedComponent) -> ExtendedComponent {
        self.components.append(child)
        child.parent = self
        return child
    }
    
    func addChild(type: ComponentType, range: OffsetRange, name: String? = nil) -> ExtendedComponent {
        let child = ExtendedComponent(type: type, range: range, names: (name, nil))
        child.parent = self
        self.components.append(child)
        return child
    }
    
    func contains(node: ExtendedComponent) -> Bool {
        return (node.offsetRange.start >= self.offsetRange.start)
            && (node.offsetRange.end <= self.offsetRange.end)
    }
    
    func insert(node: ExtendedComponent) {
        for child in self.components {
            if child.contains(node) {
                child.insert(node)
                return
            } else if node.contains(child) {
                remove(child)
                node.addChild(child)
            }
        }
        self.addChild(node)
    }
    
    func processParameters() {
        for child in components {
            if isA(.Parameter) && child.isA(.Parameter) {
                if offsetRange == child.offsetRange {
                    remove(child)
                    parent?.addChild(child)
                } else {
                    parent?.addChild(child)
                    parent?.remove(self)
                    child.processParameters()
                    break
                }
            }
            child.processParameters()
        }
    }
    
    func removeRedundantClosures() {
        forEachReversed { $0.removeRedundantClosuresInSelf() }
    }
    
    func removeRedundantClosuresInSelf() {
        components = components.filter {
            !($0.type == .Closure && $0.components.isEmpty)
        }
    }
    
    func removeRedundantParameters() {
        forEach { if !$0.isCorrectParameter { remove($0) } }
    }
    
    func remove(component: ExtendedComponent) {
        components = components.filter { $0 != component }
    }
}

extension ExtendedComponent : Hashable {
    var hashValue: Int {
        let initialValue = offsetRange.start.hashValue + offsetRange.end.hashValue + type.hashValue
        return components.reduce(initialValue) { $0 + $1.hashValue }
    }
}

extension ExtendedComponent : Equatable {}
func ==(lhs: ExtendedComponent, rhs: ExtendedComponent) -> Bool {
    if !(lhs.offsetRange == rhs.offsetRange) { return false }
    if lhs.type != rhs.type { return false }
    
    return Set(lhs.components) == Set(rhs.components)
}
