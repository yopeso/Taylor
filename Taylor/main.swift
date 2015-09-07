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

func run () {
    let arguments = Process.arguments
    print("Arguments: \(arguments)")
    
    do {
        let parameters = try processArguments(arguments)
        print("Parameters:\(parameters)")
        
        let finder = Finder()
        let paths = try finder.arrayOfPaths(dictionary: parameters)
        print(paths)
        let temper = Temper(outputPath:"/Users/thelvis/Desktop/")
        for path in paths {
            let content = tokenizeFileAtPath(path)
            temper.checkContent(content)
        }
        temper.finishTempering()
    } catch _ {
        
    }
}

run()
