//
//  NPathComplexityRule.swift
//  Temper
//
//  Created by Mihai Seremet on 9/9/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class NPathComplexityRule : Rule {
    let rule = "NPathComplexity"
    var priority : Int = 2 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://phpmd.org/rules/codesize.html#npathcomplexity"
    var limit : Int = 100{
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }
    
    func checkComponent(component: Component) -> (isOk: Bool, message: String?, value: Int?) {
        if component.type != ComponentType.Function { return (true, nil, nil) }
        let complexity = component.rangeNPathComplexity()
        if complexity > limit {
            let name = component.name ?? "unknown"
            let message = formatMessage(name, value: complexity)
            return (false, message, complexity)
        }
        return (true , nil, complexity)
    }
    
    func formatMessage(name: String, value: Int) -> String {
        return "Method '\(name)' has a NPath Complexity of \(value). The configured NPath Complexity is \(limit)"
    }
}

extension Component {
    
    func expresionNPath() -> Int {
        return components.filter { $0.type == ComponentType.Or || $0.type == ComponentType.And }.count
    }
    
    func NPathComplexity() -> Int {
        switch type {
        case .Repeat, .While, .For:
            return 1 + rangeNPathComplexity() + expresionNPath()
        case .If:
            return NPathForIfComponent()
        case .ElseIf:
            return NPathForElseIfComponent()
        case .Else, .Case, .Brace:
            return rangeNPathComplexity()
        case .Switch:
            return expresionNPath() + rangeNPathComplexity()
        case .NilCoalescing, .Ternary:
            return 2 + expresionNPath()
        default: break
        }
        return 0
    }

    func rangeNPathComplexity() -> Int {
        if type == .Switch {
            return components.map({ $0.NPathComplexity() }).reduce(0, combine: +)
        }
        let unadmisibleComponentTypes = [ComponentType.And, .Or, .Else, .ElseIf]
        let filteredComponents = components.filter { !unadmisibleComponentTypes.contains($0.type) }
        let complexities = filteredComponents.map { $0.NPathComplexity() }
        return complexities.reduce(1, combine: *)
    }
    
    func NPathForIfComponent() -> Int {
        if let nextComponent = nextComponent() {
            if nextComponent.type == .Else || nextComponent.type == .ElseIf {
                return expresionNPath() + rangeNPathComplexity() + nextComponent.NPathComplexity()
            }
        }
        return 1 + expresionNPath() + rangeNPathComplexity()
    }
    
    func NPathForElseIfComponent() -> Int {
        var complexity = expresionNPath() + rangeNPathComplexity()
        if let nextComponent = nextComponent() {
            if nextComponent.type == .Else {
                complexity += nextComponent.rangeNPathComplexity()
            }
        }
        return complexity
    }
}