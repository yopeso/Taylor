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
    var limit : Int = 100 {
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }

    func checkComponent(component: Component) -> Result {
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
        return "Method '\(name)' has a NPath Complexity of \(value). The allowed NPath Complexity is \(limit)"
    }
}

extension Component {

    func expressionNPath() -> Int {
        return components.filter { $0.type == ComponentType.Or || $0.type == ComponentType.And }.count
    }

    func NPathComplexity() -> Int {
        return type.NPathComplexityForComponent(self)
    }

    func rangeNPathComplexity() -> Int {
        if type == .Switch {
            return components.map({ $0.NPathComplexity() }).reduce(0, combine: +)
        }
        let inadmissibleComponentTypes = [ComponentType.And, .Or, .Else, .ElseIf]
        let filteredComponents = components.filter { !inadmissibleComponentTypes.contains($0.type) }
        let complexities = filteredComponents.map { $0.NPathComplexity() }
        return complexities.reduce(1, combine: *)
    }

    func NPathForIfComponent() -> Int {
        if let nextComponent = nextComponent() where
            nextComponent.type == .Else || nextComponent.type == .ElseIf {
            return expressionNPath() + rangeNPathComplexity() + nextComponent.NPathComplexity()
        }
        return 1 + expressionNPath() + rangeNPathComplexity()
    }

    func NPathForElseIfComponent() -> Int {
        var complexity = expressionNPath() + rangeNPathComplexity()
        if let nextComponent = nextComponent() {
            if nextComponent.type == .Else {
                complexity += nextComponent.rangeNPathComplexity()
            }
        }
        return complexity
    }
}


extension ComponentType {

    var hasRange: Bool {
        return [ComponentType.Repeat, .While, .For, .Else, .Case, .Brace, .Switch].contains(self)
    }

    func NPathComplexityForComponent(component: Component) -> Int {
        if component.type.hasRange { return NPathForRangeComponent(component) }
        return NPathForNonRangeComponent(component)
    }

    private func NPathForRangeComponent(component: Component) -> Int {
        switch component.type {
        case .Repeat, .While, .For: return 1 + component.rangeNPathComplexity() + component.expressionNPath()
        case .Else, .Case, .Brace: return component.rangeNPathComplexity()
        case .Switch: return component.expressionNPath() + component.rangeNPathComplexity()
        default: return 0
        }
    }

    private  func NPathForNonRangeComponent(component: Component) -> Int {
        switch component.type {
        case .If, .Guard: return component.NPathForIfComponent()
        case .ElseIf: return component.NPathForElseIfComponent()
        case .NilCoalescing, .Ternary: return 2 + component.expressionNPath()
        default: return 0
        }
    }
}
