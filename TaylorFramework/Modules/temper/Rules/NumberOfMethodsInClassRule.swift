//
//  NumberOfMethodsInClassRule.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class NumberOfMethodsInClassRule: Rule {
    let rule = "TooManyMethods"
    var priority: Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://phpmd.org/rules/codesize.html#toomanymethods"
    var limit: Int = 10 {
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }
    
    func checkComponent(_ component: Component) -> Result {
        if component.type != ComponentType.class { return (true, nil, nil) }
        let methodsCount = getMethodsCountForComponent(component)
        let name = component.name ?? "unknown"
        if methodsCount > limit {
            let message = formatMessage(name, value: methodsCount)
            return (false, message, methodsCount)
        }
        
        return (true, nil, methodsCount)
    }
    
    func formatMessage(_ name: String, value: Int) -> String {
        return "Class '\(name)' has too many methods: \(value). The allowed number of methods in class is \(limit)"
    }
    
    fileprivate func getMethodsCountForComponent(_ component: Component) -> Int {
        return component.components.filter({ $0.isA(.function) }).count
    }
}
