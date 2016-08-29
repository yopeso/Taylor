//
//  TooManyParametersRule.swift
//  Temper
//
//  Created by Mihai Seremet on 9/30/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class ExcessiveParameterListRule: Rule {
    var rule = "ExcessiveParameterList"
    var priority: Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    var externalInfoUrl = "http://phpmd.org/rules/codesize.html#excessiveparameterlist"
    var limit = 3 {
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }
    func checkComponent(component: Component) -> Result {
        if component.type != ComponentType.Function { return (true, nil, nil) }
        let parametersCount = parametersCountForFunction(component)
        if parametersCount > limit {
            let name = component.name ?? "unknown"
            let message = formatMessage(name, value: parametersCount)
            return (false, message, parametersCount)
        }
        return (true, nil, parametersCount)
    }
    
    func formatMessage(name: String, value: Int) -> String {
        return "Method '\(name)' has \(value) parameters. The allowed number of parameters is \(limit)"
    }
    
    private func parametersCountForFunction(component: Component) -> Int {
        return component.components.filter { $0.isA(.Parameter) }.count
    }
}
