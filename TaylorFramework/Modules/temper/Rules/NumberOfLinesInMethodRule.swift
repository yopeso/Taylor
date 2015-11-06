//
//  MethodLengthRule.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


class NumberOfLinesInMethodRule : Rule {
    let rule = "ExcessiveMethodLength"
    var priority : Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://phpmd.org/rules/codesize.html#excessivemethodlength"
    private var privateLimit = 20
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
    private var linesCount = 0
    
    func checkComponent(component: Component, atPath: String) -> (isOk: Bool, message: String?, value: Int?) {
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
        return "Method '\(name)' has to many lines: \(value). The configured number of lines in method is \(limit)"
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