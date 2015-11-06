//
//  ComponentRange.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

public struct ComponentRange {
    public let startLine: Int
    public let endLine: Int
    
    public init(sl:Int, el: Int) {
        startLine = sl
        endLine = el
    }
}


extension ComponentRange: Equatable {
}

public func ==(lhs: ComponentRange, rhs: ComponentRange) -> Bool {
    return lhs.startLine == rhs.startLine &&
        lhs.endLine == rhs.endLine
}