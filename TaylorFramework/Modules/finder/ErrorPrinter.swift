//
//  ErrorPrinter.swift
//  Finder
//
//  Created by Simion Schiopu on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//


final class ErrorPrinter {
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
    
    func printWrongFilePath(wrongPath: FilePath) {
        printer.printError("File path not exist or type is wrong \(wrongPath)")
    }
    
    func printFileManagerError(path: FilePath) {
        printer.printError("File manager has not found subpath from \(path)")
    }
}