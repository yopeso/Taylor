//
//  ErrorPrinter.swift
//  Finder
//
//  Created by Simion Schiopu on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//


struct ErrorPrinter {
    let printer: Printer
    
    init(printer: Printer) {
        self.printer = printer
    }
    
    func printWrongRootPathMessage() {
        printer.printError("Root path not specified")
    }
    
    func printWrongTypeFile() {
        printer.printError("File type not specified")
    }
    
    func printMissingFileError(filePath path: FilePath) {
        printer.printError("There is no file at path \(path)")
    }
    
    func printWrongFileTypeError(filePath path: FilePath) {
        printer.printError("File at path \(path) does not match the type looking for")
    }
    
    func printSubpathsError(directoryPath path: FilePath) {
        printer.printError("File manager could not fetch subpaths of \(path)")
    }
}
