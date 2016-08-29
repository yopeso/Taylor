//
//  XcodeCoordinator.swift
//  Temper
//
//  Created by Seremet Mihai on 10/5/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

struct XcodeCoordinator: WritingCoordinator {
    func writeViolations(violations: [Violation], atPath path: String) {
        let errorsString = violations.map { $0.errorString }.reduce("", combine: +)
        fputs(errorsString, stderr)
    }
}
