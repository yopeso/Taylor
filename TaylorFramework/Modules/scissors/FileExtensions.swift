//
//  FileExtensions.swift
//  Taylor
//
//  Created by Alexandru Culeva on 4/12/16.
//  Copyright © 2016 YOPESO. All rights reserved.
//

import Foundation
import SourceKittenFramework

extension File {
    var endOffset: Int {
        return startOffset + size + 1
    }
    
    static func numberOfCharacters(m: Double, b: Double, numberOfLines: Int) -> Int {
        return Double(numberOfLines).linearFunction(slope: m, intercept: b).intValue
    }
    
    func chunkSize(_ numberOfLines: Int) -> Int {
        if numberOfLines < 500 { return contents.characters.count }
        if numberOfLines < 1000 { return File.numberOfCharacters(m: 4, b: -500, numberOfLines: numberOfLines) }
        if numberOfLines < 2000 { return File.numberOfCharacters(m: 1.5, b: 2000, numberOfLines: numberOfLines) }
        if numberOfLines < 3000 { return File.numberOfCharacters(m: 1, b: 3000, numberOfLines: numberOfLines) }
        return File.numberOfCharacters(m: 0.6, b: 4200, numberOfLines: numberOfLines)
    }
    
    
    func divideByLines() -> [File] {
        guard chunkSize(lines.count) > 0 else { return [self] }
        let numberOfChunks = contents.characters.count / chunkSize(lines.count)
        if numberOfChunks <= 1 { return [self] }
        let chunks = lines.chunk(numberOfChunks)
        
        let files = NSMutableArray()
        
        for lines in chunks {
            let offset = (files.lastObject as? File)?.startOffset ?? 0
            files.add(File(lines: lines.map { $0.content },
                startLine: lines[0].index,
                startOffset: offset))
        }
        
        return files as AnyObject as! [File] // Safe to unwrap, all objects are `File`
    }
    
    func getLineRange(_ offset: Int) -> Int {
        return startLine + getLineByOffset(offset: offset - startOffset, length: 0).0 - 1
    }
}
