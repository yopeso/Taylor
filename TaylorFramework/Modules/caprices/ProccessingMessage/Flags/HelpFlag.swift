//
//  HelpFlag.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/10/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

let HelpLong = "--help"
let HelpShort = "-h"

final class HelpFlag: Flag {
    
    let name = "HelpFlag"
    
    let HelpFileName = "Help"
    let HelpFileExtension = "txt"
    
    func execute() {
        do {
            try printHelp(HelpFileName, HelpFileExtension)
        } catch {
            errorPrinter.printError("\nCan't find help file")
            exit(1)
        }
    }
    
    func printHelp(_ path: String, _ ext: String) throws {
        let bundle = Bundle(for: type(of: self))
        guard let helpFile = bundle.path(forResource: path, ofType: ext) else {
            throw CommandLineError.cannotReadFromHelpFile
        }
        do {
            let helpMessage = try String(contentsOfFile: helpFile)
            let infoPrinter = Printer(verbosityLevel: .info)
            infoPrinter.printInfo(helpMessage)
        } catch { throw CommandLineError.cannotReadFromHelpFile }
    }
    
}
