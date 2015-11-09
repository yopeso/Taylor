//
//  CapricesExtensions.swift
//  Caprices
//
//  Created by Alex Culeva on 10/30/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let defaultErrorDictionary = [ResultDictionaryErrorKey : [EmptyString]]

extension Int {
    var isEven: Bool { return self % 2 == 0 }
    var isOdd: Bool { return self % 2 == 1 }
}

extension Dictionary where Key: Hashable {
    mutating func setIfNotExist(value: Value, forKey key: Key) {
        if self[key] == nil { self[key] = value }
    }
}

extension Dictionary where Key: Hashable, Value: Summable {
    mutating func add(value: Value, toKey key: Key) {
        if self[key] == nil { self[key] = value }
        else { self[key]! = self[key]! + value }
    }
}


protocol Summable {
    func +(lhs: Self, rhs: Self) -> Self
}

extension Array: Summable  { }
extension Int: Summable { }
extension String: Summable { }

extension Array {
    var second: Element? { return self.count > 1 ? self[1] : nil }
}

extension String {
    var lines: [String] {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
    
    var firstQuotedSubstring: String {
        do {
            let regex = try NSRegularExpression(pattern: "“([^”]*)”|\"([^\"]*)\"", options: [])
            let range = regex.rangeOfFirstMatchInString(self, options: [],
                range: NSMakeRange(0, self.characters.count))
            guard range.length > 2 else { return "" }
            return (self as NSString).substringWithRange(NSMakeRange(range.location + 1, range.length - 2))
        } catch { return "" }
    }
}