//
//  JSONCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

struct JSONCoordinator: WritingCoordinator {
    
    func writeViolations(_ violations: [Violation], atPath path: String) {
        FileManager().removeFileAtPath(path)
        let json = generateJSON(violations)
        var jsonData: Data?  = nil
        do {
            jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print("Error while creating the JSON object.")
        }
        do {
            try jsonData?.write(to: URL(fileURLWithPath: path), options: NSData.WritingOptions.withoutOverwriting)
        } catch {
            print("Error while writing the JSON object to file.")
        }
    }
    
    fileprivate func generateJSON(_ violations: [Violation]) -> [String:[[String:AnyObject]]] {
        return ["violation" : violations.map() { $0.toDictionary() }]
    } 
}

extension FileManager {
    func removeFileAtPath(_ path: String) {
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue { return }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch { print("Error while removing item at path: \(path)") }
    }
}
