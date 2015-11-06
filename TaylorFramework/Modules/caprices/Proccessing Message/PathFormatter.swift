//
//  PathFormatter.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/2/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Cocoa

typealias Path = String

let EmptyString = ""
let PathSeparator = "/"

private let TildeSymbol = "~"
private let SearchIndicator = ".*"
private let CurrentDirectorySymbol = "."
private let ParentDirectorySymbol = ".."
private let RecursiveSymbol = "*"
private let IgnoredPathPrefix = "**"

extension Path {
    
    func lastComponentFromPath() -> String {
        let pathComponents = self.componentsSeparatedByString("/")
        return pathComponents.last!
    }
    
    
    func absolutePath(analyzePath: String = NSFileManager.defaultManager().currentDirectoryPath) -> Path {
        if self.hasPrefix(TildeSymbol) { return NSHomeDirectory() + self.stringByReplacingOccurrencesOfString(TildeSymbol, withString: EmptyString) }
        if self.hasPrefix(PathSeparator) { return self }
        let concatenatedPaths = analyzePath + PathSeparator + self
        
        return concatenatedPaths.editAbsolutePath()
    }
    
    
    func formattedExcludePath(analyzePath: String = NSFileManager.defaultManager().currentDirectoryPath) -> Path {
        if self.hasPrefix(SearchIndicator) && self.hasSuffix(SearchIndicator) { return self }
        if containsSymbolAsPrefixOrSuffix(SearchIndicator) { return EmptyString }

        return self.absolutePath(analyzePath)
    }
    
    
    private func containsSymbolAsPrefixOrSuffix(symbol: String) -> Bool {
        return (self.hasPrefix(symbol) && !self.hasSuffix(symbol)) || (!self.hasPrefix(symbol) && self.hasSuffix(symbol))
    }
    
    
    private func editAbsolutePath() -> Path {
        var pathComponents = self.componentsSeparatedByString(PathSeparator)
        editPathComponentsForDotShortcuts(&pathComponents)
        checkLastPathComponentsElement(&pathComponents)
        
        return pathComponents.joinWithSeparator(PathSeparator)
    }
    
    
    private func editPathComponentsForDotShortcuts(inout pathComponents:[String]) {
        for (index, element) in pathComponents.enumerate() {
            if element == CurrentDirectorySymbol {
                pathComponents.removeAtIndex(index)
            }
            if element == ParentDirectorySymbol {
                pathComponents.removeAtIndex(index)
                pathComponents.removeAtIndex(index - 1)
            }
        }
    }
    
    
    private func checkLastPathComponentsElement(inout pathComponents: [String]) {
        if pathComponents.isEmpty { return }
        if [EmptyString, RecursiveSymbol].contains(pathComponents.last!) {
            pathComponents.removeLast()
        }
    }
    
    var isIgnoredType: Bool {
        return self.hasPrefix(IgnoredPathPrefix) || self.isEmpty
    }
    
}

extension NSFileManager {
    func isDirectory(path: String) -> Bool {
        var isDirectory = ObjCBool(false)
        self.fileExistsAtPath(path, isDirectory: &isDirectory)
        return Bool(isDirectory)
    }
}

func +(lhs: [Path], rhs: Path) -> [Path] {
    return lhs + [rhs]
}
