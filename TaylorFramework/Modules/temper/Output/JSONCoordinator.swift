//
//  JSONCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

private typealias JSON = [String:[[String:AnyObject]]]

struct JSONCoordinator: WritingCoordinator {
    
    func writeViolations(_ violations: [Violation], atPath path: String) {
        FileManager().removeFileAtPath(path)
        do {
            let json = generateJSON(from: violations)
            let data = try generateData(from: json)
            try write(data: data, at: path)
        } catch let error {
            let message = "Error while creating JSON report." + "\n" +
                          "Reason: " + error.localizedDescription
            Printer(verbosityLevel: .error).printError(message)
        }
    }
    
    private func generateJSON(from violations: [Violation]) -> JSON {
        return ["violation" : violations.map() { $0.toDictionary() }]
    }
    
    private func generateData(from json: JSON) throws -> Data {
        return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }
    
    private func write(data: Data, at path: String) throws {
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
}

extension FileManager {
    func removeFileAtPath(_ path: String) {
        var isDirectory: ObjCBool = false
        guard fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue else { return }
        do {
            try removeItem(atPath: path)
        } catch let error {
            let message = "Error while removing file at path: " + path + "\n" +
                          "Reason: " + error.localizedDescription
            Printer(verbosityLevel: .error).printError(message)
        }
    }
}
