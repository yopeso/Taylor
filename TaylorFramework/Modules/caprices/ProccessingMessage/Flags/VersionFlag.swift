//
//  VersionFlag.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/10/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

let VersionLong = "--version"
let VersionShort = "-v"

struct VersionFlag: Flag {
    
    let name = "VersionFlag"
    
    func execute() {
        let infoPrinter = Printer(verbosityLevel: .Info)
        infoPrinter.printInfo("Taylor \(version)")
    }
    
}
