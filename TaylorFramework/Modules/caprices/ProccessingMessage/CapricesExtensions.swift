//
//  CapricesExtensions.swift
//  Caprices
//
//  Created by Alex Culeva on 10/30/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

let defaultErrorDictionary = [ResultDictionaryErrorKey : [""]]

extension Int {
    var isEven: Bool { return self % 2 == 0 }
    var isOdd: Bool { return self % 2 == 1 }
}

extension Dictionary where Key: Hashable {
    mutating func setIfNotExist(_ value: Value, forKey key: Key) {
        if self[key] == nil {
            self[key] = value
        }
    }
}

extension Dictionary where Key: Hashable, Value: Summable {
    mutating func add(_ value: Value, toKey key: Key) {
        if let currentValue = self[key] {
            self[key] = currentValue + value
        } else {
            self[key] = value
        }
    }
}


protocol Summable {
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Array: Summable { }
extension Int: Summable { }
extension String: Summable { }

extension Array {
    var second: Element? { return self.count > 1 ? self[1] : nil }
}

extension Array where Element: StringType {
    var containFlags: Bool {
        return self.count == 2 && Flags.contains(String(describing: self[1]))
    }    
}

extension FileManager {
    func isDirectory(_ path: String) -> Bool {
        var isDirectory = ObjCBool(false)
        fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}
