//
//  Scissors.swift
//  Scissors
//
//  Created by Alexandru Culeva on 9/3/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct Scissors {
    /**
     Tokenizes contents of file at a given path by converting it to a tree of components.
     
     - parameter path: Absolute path to the file to be tokenized.
     
     - returns: **FileContent** containing 'path' to file and the tree of components.
     */
    func tokenizeFileAtPath(_ path: String) -> FileContent {
        guard let fileForPath = File(path: path),
                  FileManager.default.fileExists(atPath: path) else {
                return FileContent(path: "", components: [])
        }
        let tree = Tree(file: fileForPath)
        let root = tree.makeTree()
        return FileContent(path: path, components: root.components)
    }
}
