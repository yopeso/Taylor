//
//  JSONCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

struct JSONCoordinator: WritingCoordinator {
    
    func writeViolations(violations: [Violation], atPath path: String) {
        NSFileManager().removeFileAtPath(path)
        let json = generateJSON(violations)
        var jsonData: NSData?  = nil
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print("Error while creating the JSON object.")
        }
        do {
            try jsonData?.writeToFile(path, options: NSDataWritingOptions.DataWritingWithoutOverwriting)
        } catch {
            print("Error while writing the JSON object to file.")
        }
    }
    
    private func generateJSON(violations: [Violation]) -> [String:[[String:AnyObject]]] {
        return ["violation" : violations.map() { $0.toDictionary() }]
    } 
}

extension NSFileManager {
    func removeFileAtPath(path: String) {
        var isDirectory: ObjCBool = false
        if !NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) && !isDirectory { return }
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch { print("Error while removing item at path: \(path)") }
    }
}
