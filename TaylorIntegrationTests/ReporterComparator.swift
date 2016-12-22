//
//  ReporterComparator.swift
//  Swetler
//
//  Created by Seremet Mihai on 11/3/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation
import TaylorFramework

func ==(lhs: [String:AnyObject], rhs: [String:AnyObject]) -> Bool {
    let class1 = lhs["class"] as? String
    let class2 = rhs["class"] as? String
    let method1 = lhs["method"] as? String
    let method2 = rhs["method"] as? String
    if class1 != nil && class2 != nil && class1 != class2 { return false }
    if method1 != nil && method2 != nil && method1 != method2 { return false }
    if class1 != nil && class2 == nil || class1 == nil && class2 != nil { return false }
    if method1 != nil && method2 == nil || method1 == nil && method2 != nil { return false }
    return  lhs["startLine"] as! Int == rhs["startLine"] as! Int &&
            lhs["endLine"] as! Int == rhs["endLine"] as! Int &&
            lhs["value"] as! Int == rhs["value"] as! Int &&
            lhs["message"] as! String == rhs["message"] as! String &&
            lhs["rule"] as! String == rhs["rule"] as! String &&
            lhs["priority"] as! Int == rhs["priority"] as! Int &&
            lhs["externalInfoUrl"] as! String == rhs["externalInfoUrl"] as! String
}

func !=(lhs: [String:AnyObject], rhs: [String:AnyObject]) -> Bool {
    return !(lhs == rhs)
}

class JSONReportComparator {
    func compareReport(atPath path1: String, withReportAtPath path2: String) -> Bool {
        var violations1 = JSONToViolationParser().parseFile(path1)
        violations1 = violations1.map { ( violation: [String:AnyObject]) -> [String:AnyObject] in
            var violationCopy = violation
            violationCopy["path"] = "" as AnyObject?
            return violationCopy
        }
        var violations2 = JSONToViolationParser().parseFile(path2)
        violations2 = violations2.map { (violation: [String:AnyObject]) -> [String:AnyObject] in
            var violationCopy = violation
            violationCopy["path"] = "" as AnyObject?
            return violationCopy
        }
        guard violations1.count == violations2.count else { return false }
        for i in 0 ..< violations1.count {
            if violations1[i] != violations2[i] {
                return false
            }
        }
        
        return true
    }
    
}
