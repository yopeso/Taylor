//
//  PathFormatter.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/2/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Cocoa

typealias Path = String

private let TildeSymbol = "~"
private let SearchIndicator = ".*"
private let CurrentDirectorySymbol = "."
private let ParentDirectorySymbol = ".."
private let RecursiveSymbol = "*"

extension Path {
    
    func lastComponentFromPath() -> String {
        if self.isEmpty { return String.Empty }
        let pathComponents = self.componentsSeparatedByString(FilePath.Separator)
        return pathComponents.last! // Safe to force unwrap
    }
    
    
    func absolutePath(analyzePath: String = NSFileManager.defaultManager().currentDirectoryPath) -> Path {
        if self.hasPrefix(TildeSymbol) { return NSHomeDirectory() + self.stringByReplacingOccurrencesOfString(TildeSymbol, withString: String.Empty) }
        if self.hasPrefix(FilePath.Separator) { return self }
        let concatenatedPaths = analyzePath + FilePath.Separator + self
        
        return concatenatedPaths.editAbsolutePath()
    }
    
    
    func formattedExcludePath(analyzePath: String = NSFileManager.defaultManager().currentDirectoryPath) -> Path {
        if self.hasPrefix(SearchIndicator) && self.hasSuffix(SearchIndicator) { return self }
        if containsSymbolAsPrefixOrSuffix(SearchIndicator) { return String.Empty }

        return self.absolutePath(analyzePath)
    }
    
    
    private func containsSymbolAsPrefixOrSuffix(symbol: String) -> Bool {
        return (self.hasPrefix(symbol) && !self.hasSuffix(symbol)) || (!self.hasPrefix(symbol) && self.hasSuffix(symbol))
    }
    
    
    private func editAbsolutePath() -> Path {
        var pathComponents = self.componentsSeparatedByString(FilePath.Separator)
        editPathComponentsForDotShortcuts(&pathComponents)
        checkLastPathComponentsElement(&pathComponents)
        
        return pathComponents.joinWithSeparator(FilePath.Separator)
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
        if [String.Empty, RecursiveSymbol].contains(pathComponents.last!) {
            pathComponents.removeLast()
        }
    }
}
