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
    let fileManager = FileManager.default
    
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
        //TODO: Review/redo pacman execution
        removeMap()
        guard !paths.isEmpty && createMap() else {
            print("An unexpected error occured when launching Pacman.")
            return
        }
        let task = Process()
        let path = getGamePath()
        
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", "Terminal.app", path.stringByAppendingPathComponent("pacman.py")]
        task.launch()
        sleep(4)
        removeMap()
    }
    
    func getGamePath() -> String {
        guard let path =  Bundle(for: type(of: self)).path(forResource: "pacman", ofType: "py") else {
            print("Can't find game path for Easter Egg :o")
            return ""
        }
        
        return (path as NSString).deletingLastPathComponent
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
            if !fileManager.fileExists(atPath: dataPath) {
                try fileManager.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
            }
            try mapText.write(toFile: dataPath + "/map.dat", atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch { return false }
    }
    
    func removeMap() {
        let dataPath = "\(NSHomeDirectory())" + "/tmp"
        _ = try? fileManager.removeItem(atPath: dataPath)
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
    
    func generateMapString(_ text: String) -> String? {
        if text.isEmpty || text.characters.count < mapString.characters.count { return nil }
        let endIndex = mapString.characters.count + Int(arc4random_uniform(UInt32(text.characters.count - mapString.characters.count)))
        let textRange = text.characters.index(text.startIndex, offsetBy: endIndex - mapString.characters.count)..<text.characters.index(text.startIndex, offsetBy: endIndex)
        var charactersGenerator = text.substring(with: textRange).characters.makeIterator()
        let restrictedChars = [PLAYER, GHOST, "\n", POINT]
        return String(mapString.characters.map { character in
            if character != WALL_VAR { return character }
            guard let replaceChar = charactersGenerator.next() , !restrictedChars.contains(replaceChar) else { return Character(" ") }
            return replaceChar
        })
    }
    
    func getText() -> String {
        var pathsGenerator = paths.shuffle().makeIterator()
        let charNumber = countWallCharacters()
        while let path = pathsGenerator.next() {
            if let file = File(path: path), charNumber < file.contents.characters.count {
                return file.contents
            }
        }
        return ""
    }
}
