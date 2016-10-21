//
//  NumberOfLinesInClassRule.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class NumberOfLinesInClassRule: Rule {
    let rule = "ExcessiveClassLength"
    var priority: Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://phpmd.org/rules/codesize.html#excessiveclasslength"
    var limit: Int = 400 {
        willSet {
            if newValue > 0 {
                self.limit = newValue
            }
        }
    }
    fileprivate var linesCount = 0
    
    func checkComponent(_ component: Component) -> Result {
        if component.type != ComponentType.class { return (true, nil, nil) }
        linesCount = component.range.length
        deleteLinesFromComponent(component)
        if linesCount > limit {
            let name = component.name ?? "unknown"
            let message = formatMessage(name, value: linesCount)
            return (false, message, linesCount)
        }
        
        return (true, nil, linesCount)
    }
    
    func formatMessage(_ name: String, value: Int) -> String {
        return "Class '\(name)' has too many lines: \(value). The allowed number of lines in a class is \(limit)"
    }

    fileprivate func deleteLinesFromComponent(_ component: Component) {
        let _ = component.components.map({ (component: Component) -> Void in
            if component.isRedundantLine {
                linesCount -= component.range.length + 1
            }
            deleteLinesFromComponent(component)
        })
    }
}
