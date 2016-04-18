//
//  PacMan.swift
//  Scissors
//
//  Created by Alex Culeva on 9/25/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework

let WALL_CONST = Character("#")
let WALL_VAR = Character("H")
let PLAYER = Character("@")
let GHOST = Character("$")
let POINT = Character(".")

final class Pacman {
    let paths: [String]
    let fileManager = NSFileManager.defaultManager()
    
    /**
    Initialize Pacman with an array of paths
    
    - parameter paths: paths to files for the map to be generated from.
    */
    init(paths: [String]) {
        self.paths = paths
    }
    
    /**
    Starts pacman game by generating a map using text from one of the files in *paths*.
    If no paths were given, no game instance will run.
    */
    func start() {
        guard !paths.isEmpty && createMap() else {
            print("An unexpected error occured when launching Pacman.")
            return
        }
        let path = getGamePath()
        system("cd " + path)
        system("python " + path + "/pacman.py")
        removeMap()
    }
    
    func getGamePath() -> String {
        let path =  NSBundle(forClass: self.dynamicType).pathForResource("pacman", ofType: "py")
        return (path ?? "" as NSString).stringByDeletingLastPathComponent
    }
    
    /**
    Returns *true* if map file successfully created or *false* if not.
    */
    func createMap() -> Bool {
        let path = getGamePath()
        guard let mapFile = File(path: path.stringByAppendingPathComponent("/prototype_map.dat")) else {
            return false
        }
        let generator = Generator(map: mapFile.contents, paths: paths)
        let mapText = generator.generateMapString(generator.getText()) ?? mapFile.contents
        let dataPath = "\(NSHomeDirectory())" + "/tmp"
        do {
            if !fileManager.fileExistsAtPath(dataPath) {
                try fileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: true, attributes: nil)
            }
            try mapText.writeToFile(dataPath + "/map.dat", atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch { return false }
    }
    
    func removeMap() {
        let dataPath = "\(NSHomeDirectory())" + "/tmp"
        _ = try? fileManager.removeItemAtPath(dataPath)
    }
}

struct Generator {
    let mapString: String
    let paths: [String]
    
    init(map: String, paths: [String]) {
        mapString = map
        self.paths = paths
    }
    
    func countWallCharacters() -> Int {
        return mapString.characters.filter { $0 == WALL_CONST }.count
    }
    
    func generateMapString(text: String) -> String? {
        if text.isEmpty || text.characters.count < mapString.characters.count { return nil }
        let endIndex = mapString.characters.count + Int(arc4random_uniform(UInt32(text.characters.count - mapString.characters.count)))
        let textRange = text.startIndex.advancedBy(endIndex - mapString.characters.count)..<text.startIndex.advancedBy(endIndex)
        var charactersGenerator = text.substringWithRange(textRange).characters.generate()
        let restrictedChars = [PLAYER, GHOST, "\n", POINT]
        return String(mapString.characters.map { character in
            if character != WALL_VAR { return character }
            guard let replaceChar = charactersGenerator.next() where !restrictedChars.contains(replaceChar) else { return Character(" ") }
            return replaceChar
        })
    }
    
    func getText() -> String {
        var pathsGenerator = paths.shuffle().generate()
        let charNumber = countWallCharacters()
        while let path = pathsGenerator.next() {
            if let file = File(path: path) where charNumber < file.contents.characters.count {
                return file.contents
            }
        }
        return ""
    }
}
