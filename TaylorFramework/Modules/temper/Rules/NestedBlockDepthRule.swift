//
//  NestedBlockDepthRule.swift
//  Temper
//
//  Created by Mihai Seremet on 9/9/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class NestedBlockDepthRule : Rule {
    let rule = "NestedBlockDepth"
    var priority : Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://docs.oclint.org/en/dev/rules/size.html#nestedblockdepth"
    let admissibleComponents = [ComponentType.If, .While, .For, .Case, .Brace, .Repeat, .Switch, .Brace, .Guard]
    var limit : Int = 3 {
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }
    
    func checkComponent(component: Component) -> Result {
        if component.type != ComponentType.Function { return (true, nil, nil) }
        let depth = findMaxDepthForComponent(component)
        if depth > limit {
            let name = component.name ?? "unknown"
            let message = formatMessage(name, value: depth)
            return (false, message, depth)
        }
        
        return (true, nil, depth)
    }
    
    func formatMessage(name: String, value: Int) -> String {
        return "Method '\(name)' has a block depth of \(value). The configured block depth is \(limit)"
    }
    
    private func findMaxDepthForComponent(component: Component) -> Int {
        if !checkForAdmisibleComponents(component.components) || component.components.count == 0 {
            return 0
        }
        
        let depths = component.components.map { findMaxDepthForComponent($0) }
        if let maxElement = depths.maxElement() {
            return maxElement + 1
        }
        
        return 0
    }
    
    private func checkForAdmisibleComponents(components: [Component]) -> Bool {
        let commonTypes = Set(components.map({ $0.type })).intersect(Set(admissibleComponents))
        
        return !commonTypes.isEmpty
    }
}
