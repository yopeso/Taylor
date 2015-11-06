//
//  NumberOfMethodsInClassRule.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


class NumberOfMethodsInClassRule : Rule {
    let rule = "TooManyMethods"
    var priority : Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://phpmd.org/rules/codesize.html#toomanymethods"
    private var privateLimit = 10
    var limit : Int {
        get {
            return privateLimit
        }
        set {
            if newValue > 0 {
                privateLimit = newValue
            }
        }
    }
    
    func checkComponent(component: Component, atPath: String) -> (isOk: Bool, message: String?, value: Int?) {
        if component.type != ComponentType.Class { return (true, nil, nil) }
        let methodsCount = getMethodsCountForComponent(component)
        let name = component.name ?? "unknown"
        if methodsCount > limit {
            let message = formatMessage(name, value: methodsCount)
            return (false, message, methodsCount)
        }

        return (true, nil, methodsCount)
    }
    
    func formatMessage(name: String, value: Int) -> String {
        return "Class '\(name)' has to many methods: \(value). The configured number of methods in class is \(limit)"
    }
    
    private func getMethodsCountForComponent(component: Component) -> Int {
        return component.components.filter({ $0.type == ComponentType.Function }).count
    }
}