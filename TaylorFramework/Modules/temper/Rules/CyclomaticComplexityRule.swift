//
//  CyclomaticComplexityRule.swift
//  Temper
//
//  Created by Mihai Seremet on 9/9/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class CyclomaticComplexityRule : Rule {
    let rule = "CyclomaticComplexity"
    var priority : Int = 2 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let  externalInfoUrl  = "http://phpmd.org/rules/codesize.html#cyclomaticcomplexity"
    var limit : Int = 5 {
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }
    private let decisionalComponentTypes = [ComponentType.If, .While, .For, .Case, .ElseIf, .Ternary, .NilCoalescing, .Guard]
    
    func checkComponent(component: Component) -> Result {
        if component.type != ComponentType.Function { return (true, nil, nil) }
        let complexity = findComplexityForComponent(component) + 1
        if complexity > limit {
            let name = component.name ?? "unknown"
            let message = formatMessage(name, value: complexity)
            return (false, message, complexity)
        }
        return (true, nil, complexity)
    }
    
    func formatMessage(name: String, value: Int) -> String {
        return "The method '\(name)' has a Cyclomatic Complexity of \(value). The allowed Cyclomatic Complexity is \(limit)"
    }
    
    private func findComplexityForComponent(component: Component) -> Int {
        let complexity = decisionalComponentTypes.contains(component.type) ? 1 : 0
        return component.components.map({ findComplexityForComponent($0) }).reduce(complexity, combine: +)
    }
}
