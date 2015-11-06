//
//  Scissors.swift
//  Scissors
//
//  Created by Alexandru Culeva on 9/3/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import BoundariesKit
import SourceKittenFramework
import Printer

public class Scissors {
    let printer: Printer
    
    /**
    Initialize Scissors by passing in a Printer.
    - parameter printer: Printer to be used as message or error output.
    */
    public init(printer: Printer = Printer(verbosityLevel: VerbosityLevel.Error)) {
        self.printer = printer
    }
    
    /**
    Tokenizes contents of file at a given path by converting it to a tree of components.
    
    - parameter path: Absolute path to the file to be tokenized.
    
    - returns: **FileContent** containing 'path' to file and the tree of components.
    */
    public func tokenizeFileAtPath(path: String) -> FileContent {
        printer.printInfo("Processing \(path)")
        let tree = Tree(file: File(path: path)!)
        let root = tree.makeTree()
        return FileContent(path: path, components: root.components)
    }
}
