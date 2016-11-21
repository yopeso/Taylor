//
//  PLAINCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

final class PLAINCoordinator: WritingCoordinator {
    func writeViolations(_ violations: [Violation], atPath path: String) {
        FileManager().removeFileAtPath(path)
        let content = generateFileContentFromViolations(violations)
        do {
            try content.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        } catch _ {
            print("Error while trying to write the content of string in file.")
        }
    }
    
    fileprivate func generateFileContentFromViolations(_ violations: [Violation]) -> String {
        let mappedViolations = violations.map({ $0.toString })
        return mappedViolations.reduce(generateFileContentHeader(), +)
    }
    
    fileprivate func generateFileContentHeader() -> String {
        return "\nSummary: TotalFiles=\(Temper.statistics.totalFiles) FilesWithViolations=\(Temper.statistics.filesWithViolations) " +
            "P1=\(Temper.statistics.violationsWithP1) P2=\(Temper.statistics.violationsWithP2) P3=\(Temper.statistics.violationsWithP3)\n\n"
    }
}
