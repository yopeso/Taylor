//
//  NumberOfLinesInClassRule.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


final class NumberOfLinesInClassRule : Rule {
    let rule = "ExcessiveClassLength"
    var priority : Int = 3 {
        willSet {
            if newValue > 0 {
                self.priority = newValue
            }
        }
    }
    let externalInfoUrl = "http://phpmd.org/rules/codesize.html#excessiveclasslength"
    private var privateLimit = 400
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
    
    func checkComponent(component: Component) -> (isOk: Bool, message: String?, value: Int?) {
        if component.type != ComponentType.Class { return (true, nil, nil) }
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
        return "Class '\(name)' has to many lines: \(value). The configured number of lines in class is \(limit)"
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