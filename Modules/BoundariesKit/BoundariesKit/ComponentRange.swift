//
//  ComponentRange.swift
//  BoundariesKit
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

public struct ComponentRange {
    public let startLine: Int
    public let startColumn: Int
    public let endLine: Int
    public let endColumn: Int
    
    public init(sl:Int, sc: Int, el: Int, ec: Int) {
        startLine = sl
        startColumn = sc
        endLine = el
        endColumn = ec
    }
}


extension ComponentRange: Equatable {
}

public func ==(lhs: ComponentRange, rhs: ComponentRange) -> Bool {
    return lhs.startLine == rhs.startLine &&
        lhs.startColumn == rhs.startColumn &&
        lhs.endLine == rhs.endLine &&
        rhs.endLine == rhs.endLine
}