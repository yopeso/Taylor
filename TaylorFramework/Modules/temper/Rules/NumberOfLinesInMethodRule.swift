//
//  MethodLengthRule.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class NumberOfLinesInMethodRule: Rule {
    let rule = "ExcessiveMethodLength"
    var priority: Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://phpmd.org/rules/codesize.html#excessivemethodlength"
    var limit: Int = 20 {
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }
    private var linesCount = 0
    
    func checkComponent(component: Component) -> Result {
        if component.type != ComponentType.Function { return (true, nil, nil) }
        linesCount = component.range.length
        deleteLinesFromComponent(component)
        if linesCount > limit {
            let name = component.name ?? "unknown"
            let message = formatMessage(name, value: linesCount)
            return (false, message, linesCount)
        }
        
        return (true, nil, linesCount)
    }
    
    func formatMessage(name: String, value: Int) -> String {
        return "Method '\(name)' has too many lines: \(value). The allowed number of lines in a method is \(limit)"
    }
    
    private func deleteLinesFromComponent(component: Component) {
        let _ = component.components.map({ (component: Component) -> Void in
            if component.isRedundantLine {
                linesCount -= component.range.length + 1
            }
            deleteLinesFromComponent(component)
        })
    }
}
