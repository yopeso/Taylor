//
//  OutputCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

final class OutputCoordinator {
    var filePath: String
    var reporters = [Reporter]()
    
    init(filePath: String) {
        self.filePath = filePath
    }
    
    func writeTheOutput(_ violations: [Violation], reporters: [Reporter]) {
        self.reporters = reporters
        for reporter in reporters {
            write(violations: violations, with: reporter)
        }
    }
    
    private func write(violations: [Violation], with reporter: Reporter) {
        if reporter.fileName.isEmpty && (reporter.concreteReporter as? XcodeReporter) == nil { return }
        let outputPath = reporter.fileName.absolutePath(filePath)
        reporter.coordinator().writeViolations(violations, atPath: outputPath)
    }
}

protocol WritingCoordinator {
    func writeViolations(_ violations: [Violation], atPath path: String)
}
