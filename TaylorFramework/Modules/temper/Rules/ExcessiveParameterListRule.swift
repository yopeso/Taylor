//
//  TooManyParametersRule.swift
//  Temper
//
//  Created by Mihai Seremet on 9/30/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


class ExcessiveParameterListRule : Rule {
    var rule = "ExcessiveParameterList"
    var priority : Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    var externalInfoUrl = "http://phpmd.org/rules/codesize.html#excessiveparameterlist"
    var limit = 3
    func checkComponent(component: Component, atPath: String) -> (isOk: Bool, message: String?, value: Int?) {
        if component.type != ComponentType.Function { return (true, nil, nil) }
        let parametersCount = parametersCountForFunction(component)
        if parametersCount > limit {
            let name = component.name ?? "unknown"
            let message = formatMessage(name, value: parametersCount)
            return (false, message, parametersCount)
        }
        return (true , nil, parametersCount)
    }
    
    func formatMessage(name: String, value: Int) -> String {
        return "Method '\(name)' has \(value) parameters. The configured number of parameters is \(limit)"
    }
    
    private func parametersCountForFunction(component: Component) -> Int {
        return component.components.filter { $0.type == ComponentType.Parameter }.count
    }
}