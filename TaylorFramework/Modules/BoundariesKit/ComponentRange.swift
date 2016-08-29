//
//  ComponentRange.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

struct ComponentRange {
    let startLine: Int
    let endLine: Int
    
    init(sl: Int, el: Int) {
        startLine = sl
        endLine = el
    }
}


extension ComponentRange: Equatable {
}

func ==(lhs: ComponentRange, rhs: ComponentRange) -> Bool {
    return lhs.startLine == rhs.startLine &&
        lhs.endLine == rhs.endLine
}
