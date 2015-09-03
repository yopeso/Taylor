//
//  main.swift
//  Taylor
//
//  Created by Andrei Raifura on 9/3/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

import Caprice
import Finder
import Scissors
import Temper

func isDebug() -> Bool {
    #if DEBUG
        return true
   #else
        return false
    #endif
}

func getArguments() -> [String] {
    if isDebug() {
        var arguments = Process.arguments
        return arguments.removeLastElements(2)
    } else {
        return Process.arguments
    }
}

extension Array {
    mutating func removeLastElements(numberOfElements: Int) -> Array {
        for _ in 0..<numberOfElements {
            self.removeLast()
        }
        
        return self
    }
}

func run () {
    let arguments = getArguments()
    let parameters = processArguments(arguments)
    
    let finder = Finder()
    let paths = finder.arrayOfPaths(dictionary: parameters)
    print(paths)
    
    let temper = Temper(outputPath:"/Users/thelvis/Desktop/")
    for path in paths {
        let content = FileReader().pathToFileContent(path)
        temper.checkContent(content)
    }
    temper.finishTempering()
}

run()
