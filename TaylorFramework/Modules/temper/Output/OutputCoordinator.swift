//
//  OutputCoordinator.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

class OutputCoordinator {
    var filePath : String
    var reporters = [Reporter]()
    
    init(filePath: String) {
        self.filePath = filePath
    }
    
    func writeTheOutput(violations: [Violation], reporters: [Reporter]) {
        self.reporters = reporters
        var coordinator : WritingCoordinator
        for reporter in reporters {
            switch reporter.type {
            case .JSON:  coordinator = JSONCoordinator()
            case .PMD:   coordinator = PMDCoordinator()
            case .Plain: coordinator = PLAINCoordinator()
            case .Xcode: coordinator = XcodeCoordinator()
            }
            let path = (filePath as NSString).stringByAppendingPathComponent(reporter.fileName)
            coordinator.writeViolations(violations, atPath: path)
        }
    }
}

protocol WritingCoordinator {
    func writeViolations(violations: [Violation], atPath path: String)
}