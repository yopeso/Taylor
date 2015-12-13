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
            try printHelp()
        } catch {
            errorPrinter.printError("\nCan't find help file")
            exit(1)
        }
    }
    
    private func printHelp() throws {
        let bundle = NSBundle(forClass: self.dynamicType)
        guard let helpFile = bundle.pathForResource(HelpFileName, ofType: HelpFileExtension) else {
            throw CommandLineError.CannotReadFromHelpFile
        }
        do {
            let helpMessage = try String(contentsOfFile: helpFile)
            let infoPrinter = Printer(verbosityLevel: .Info)
            infoPrinter.printInfo(helpMessage)
        } catch { throw CommandLineError.CannotReadFromHelpFile }
    }
    
}
