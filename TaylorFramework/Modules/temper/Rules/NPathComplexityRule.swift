//
//  NPathComplexityRule.swift
//  Temper
//
//  Created by Mihai Seremet on 9/9/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class NPathComplexityRule: Rule {
    let rule = "NPathComplexity"
    var priority: Int = 2 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://phpmd.org/rules/codesize.html#npathcomplexity"
    var limit: Int = 100 {
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }
    
    func checkComponent(_ component: Component) -> Result {
        if component.type != ComponentType.function { return (true, nil, nil) }
        let complexity = component.rangeNPathComplexity()
        if complexity > limit {
            let name = component.name ?? "unknown"
            let message = formatMessage(name, value: complexity)
            return (false, message, complexity)
        }
        return (true, nil, complexity)
    }
    
    func formatMessage(_ name: String, value: Int) -> String {
        return "Method '\(name)' has a NPath Complexity of \(value). The allowed NPath Complexity is \(limit)"
    }
}

extension Component {
    
    func expressionNPath() -> Int {
        return components.filter { $0.isA(.or) || $0.isA(.and) }.count
    }
    
    func NPathComplexity() -> Int {
        return type.NPathComplexityForComponent(self)
    }
    
    func rangeNPathComplexity() -> Int {
        if type == .switch {
            return components.map({ $0.NPathComplexity() }).reduce(0, +)
        }
        let inadmissibleComponentTypes = [ComponentType.and, .or, .else, .elseIf]
        let filteredComponents = components.filter { !inadmissibleComponentTypes.contains($0.type) }
        let complexities = filteredComponents.map { $0.NPathComplexity() }
        return complexities.reduce(1, *)
    }
    
    func NPathForIfComponent() -> Int {
        if let nextComponent = nextComponent() ,
            nextComponent.isA(.else) || nextComponent.isA(.elseIf) {
            return expressionNPath() + rangeNPathComplexity() + nextComponent.NPathComplexity()
        }
        return 1 + expressionNPath() + rangeNPathComplexity()
    }
    
    func NPathForElseIfComponent() -> Int {
        var complexity = expressionNPath() + rangeNPathComplexity()
        if let nextComponent = nextComponent() {
            if nextComponent.isA(.else) {
                complexity += nextComponent.rangeNPathComplexity()
            }
        }
        return complexity
    }
}


extension ComponentType {
    
    var hasRange: Bool {
        return [ComponentType.repeat, .while, .for, .else, .case, .brace, .switch].contains(self)
    }
    
    func NPathComplexityForComponent(_ component: Component) -> Int {
        if component.type.hasRange { return NPathForRangeComponent(component) }
        return NPathForNonRangeComponent(component)
    }
    
    fileprivate func NPathForRangeComponent(_ component: Component) -> Int {
        switch component.type {
        case .repeat, .while, .for: return 1 + component.rangeNPathComplexity() + component.expressionNPath()
        case .else, .case, .brace: return component.rangeNPathComplexity()
        case .switch: return component.expressionNPath() + component.rangeNPathComplexity()
        default: return 0
        }
    }
    
    fileprivate  func NPathForNonRangeComponent(_ component: Component) -> Int {
        switch component.type {
        case .if, .guard: return component.NPathForIfComponent()
        case .elseIf: return component.NPathForElseIfComponent()
        case .nilCoalescing, .ternary: return 2 + component.expressionNPath()
        default: return 0
        }
    }
}
