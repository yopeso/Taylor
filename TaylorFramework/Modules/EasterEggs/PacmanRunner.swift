//
//  PacmanRunner.swift
//  Taylor
//
//  Created by Dmitrii Celpan on 11/11/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Cocoa

class PacmanRunner {
    
    let printer = Printer(verbosityLevel: .error)
    let currentPath = FileManager.default.currentDirectoryPath
    
    func runEasterEggPrompt() {
        printer.printError("Taylor is mad! Would you like to play with her(it)? (Y/N)")
        runEasterEggIfNeeded(input())
    }
    
    func runEasterEggIfNeeded(_ userInput: String) {
        if userInput.uppercased() == "Y" {
            let paths = filePaths(for: currentPath)
            runEasterEgg(paths)
        } else {
            printer.printError("O Kay! Next time :)")
        }
    }
    
    func formatInputString(_ string: String) -> String {
        return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func input() -> String {
        let keyboard = FileHandle.standardInput
        let inputData = keyboard.availableData
        return String(String(data: inputData, encoding: String.Encoding.utf8)?.characters.first ?? Character(""))
    }
    
    func runEasterEgg(_ paths: [Path]) {
        let pacman = Pacman(paths: paths)
        pacman.start()
    }
    
    func filePaths(for path: Path) -> [Path] {
        let parameters = ["path": [currentPath], "type": ["swift"]]
        return Finder().findFilePaths(parameters: parameters)
    }

}
