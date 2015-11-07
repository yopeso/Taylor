//
//  Utilities.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

infix operator ~== { associativity left }
func ~== (a: String?, b: String?) -> Bool {
    if a == nil && b == nil {
        return true
    }
    
    if a == nil || b == nil {
        return false
    }
    
    return a == b
}

infix operator !~== { associativity left }
func !~== (a: String?, b: String?) -> Bool {
    return !(a ~== b)
}