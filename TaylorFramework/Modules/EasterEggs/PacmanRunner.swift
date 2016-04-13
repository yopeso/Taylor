//
//  PacmanRunner.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/11/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Cocoa

class PacmanRunner {
    
    let printer = Printer(verbosityLevel: .Error)
    let currentPath = NSFileManager.defaultManager().currentDirectoryPath
    
    func runEasterEggPrompt() {
        printer.printError("Taylor is mad! Would you like to play with her(it)? (Y/N)")
        runEasterEggIfNeeded(input())
    }
    
    func runEasterEggIfNeeded(userInput: String) {
        if userInput.uppercaseString == "Y" {
            let paths = filePathsForPath(currentPath)
            runEasterEgg(paths)
        } else {
            printer.printError("O Kay! Next time :)")
        }
    }
    
    func formatInputString(string: String) -> String {
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
    }
    
    func input() -> String {
        let keyboard = NSFileHandle.fileHandleWithStandardInput()
        let inputData = keyboard.availableData
        return String(String(data: inputData, encoding: NSUTF8StringEncoding)?.characters.first ?? Character(""))
    }
    
    func runEasterEgg(paths: [Path]) {
        let pacman = Pacman(paths: paths)
        pacman.start()
    }
    
    func filePathsForPath(path: Path) -> [Path] {
        let parameters = ["path": [currentPath], "type": ["swift"]]
        return Finder().findFilePaths(parameters: parameters)
    }

}
