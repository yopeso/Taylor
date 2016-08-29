//
//  PLAINCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

final class PLAINCoordinator: WritingCoordinator {
    func writeViolations(violations: [Violation], atPath path: String) {
        NSFileManager().removeFileAtPath(path)
        let content = generateFileContentFromViolations(violations)
        do {
            try content.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ {
            print("Error while trying to write the content of string in file.")
        }
    }
    
    private func generateFileContentFromViolations(violations: [Violation]) -> String {
        let mappedViolations = violations.map({ $0.toString })
        return mappedViolations.reduce(generateFileContentHeader(), combine: +)
    }
    
    private func generateFileContentHeader() -> String {
        return "\nSummary: TotalFiles=\(Temper.statistics.totalFiles) FilesWithViolations=\(Temper.statistics.filesWithViolations) " +
            "P1=\(Temper.statistics.violationsWithP1) P2=\(Temper.statistics.violationsWithP2) P3=\(Temper.statistics.violationsWithP3)\n\n"
    }
}
