//
//  PacMan.swift
//  Scissors
//
//  Created by Alex Culeva on 9/25/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

import Foundation
import SourceKittenFramework

let WALL_CONST = "#"
let WALL_VAR = "H"
let PLAYER = "@"
let GHOST = "$"
let POINT = "."

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
        if paths.isEmpty { return }
        let path = getGamePath()
        createMap()
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
        let mapFile = File(path: path.stringByAppendingPathComponent("/prototype_map.dat"))
        if mapFile == nil { return false }
        let generator = Generator(map: (mapFile!.contents) ?? "", paths: paths)
        let mapText = generator.generateMapString(generator.getText())
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
        if fileManager.fileExistsAtPath(dataPath) {
            do {
                try fileManager.removeItemAtPath(dataPath)
            } catch { }
        }
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
        return mapString.characters.filter() { String($0) == WALL_CONST }.count
    }
    
    func generateMapString(text: String) -> String {
        if text.isEmpty { return "" }
        let endIndex = mapString.characters.count + Int(arc4random_uniform(UInt32(text.characters.count-mapString.characters.count)))
        let textRange = text.startIndex.advancedBy(endIndex-mapString.characters.count)..<text.startIndex.advancedBy(endIndex)
        let newText = text.substringWithRange(textRange)
        var map = "", i = 0
        let restrictedChars = [PLAYER, GHOST, "\n", POINT]
        for character in mapString.characters {
            if "\(character)" == WALL_VAR {
                let replaceChar = newText.characters[newText.startIndex.advancedBy(i)]
                if restrictedChars.contains(String(replaceChar)){ map.append(" " as Character) }
                else { map.append(replaceChar) }
                i += 1
            } else {
                map.append(character)
            }
        }
        return map
    }
    
    func getText() -> String {
        var file: File = File(contents: "")
        let charNumber = countWallCharacters()
        while file.contents.characters.count < charNumber {
            let path = paths[Int(arc4random_uniform(UInt32(paths.count-1)))]
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                file = File(path: path)! // Safe to force unwrap
            } else { return "" }
        }
        return file.contents
    }
}