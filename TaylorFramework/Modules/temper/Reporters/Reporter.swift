//
//  Reporter.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

protocol Reporting {
    /**
     This method should return the file extension for reporter file
     
     For Xcode type it return "" because Xcode type don't have a file name
     
     :returns: String The file extension
     */
    func fileExtension() -> String
    
    /**
     This method should return the default reporter file the type
     
     For Xcode type it return "" because Xcode type don't have a file name
     
     :returns: String The file name of the reporter
     */
    func defaultFileName() -> String
    
    func coordinator() -> WritingCoordinator
}


struct PlainReporter: Reporting {
    func fileExtension() -> String {
        return "txt"
    }
    
    func defaultFileName() -> String {
        return "taylor_report" + "." + fileExtension()
    }
    
    func coordinator() -> WritingCoordinator {
        return PLAINCoordinator()
    }
}

struct PMDReporter: Reporting {
    func fileExtension() -> String {
        return "pmd"
    }
    
    func defaultFileName() -> String {
        return "taylor_report" + "." + fileExtension()
    }
    
    func coordinator() -> WritingCoordinator {
        return PMDCoordinator()
    }
}

struct XcodeReporter: Reporting {
    func fileExtension() -> String {
        return ""
    }
    
    func defaultFileName() -> String {
        return ""
    }
    
    func coordinator() -> WritingCoordinator {
        return XcodeCoordinator()
    }
}

struct JSONReporter: Reporting {
    func fileExtension() -> String {
        return "json"
    }
    
    func defaultFileName() -> String {
        return "taylor_report" + "." + fileExtension()
    }
    
    func coordinator() -> WritingCoordinator {
        return JSONCoordinator()
    }
}


struct Reporter: Reporting {
    let concreteReporter: Reporting
    let fileName: String
    
    /**
     Initialize the reporter with type and name
     
     If no file name is given the default file name is used:
     * PMD (temper_report.pmd)
     * JSON (temper_report.json)
     * Plain (temper_report.txt)
     * Xcode (dan't have a file name)
     
     :param: type The type of the reporter
     * JSON
     * PMD
     * Plain
     * Xcode
     */

    
    init(type: String, fileName: String? = nil) {
        self.concreteReporter = reporterWithName(type)
        guard let fileName = fileName else {
            self.fileName = self.concreteReporter.defaultFileName()
            return
        }
        self.fileName  = fileName
    }
    
    init(_ concreteReporter: Reporting) {
        self.concreteReporter = concreteReporter
        self.fileName = concreteReporter.defaultFileName()
    }
    
    func fileExtension() -> String {
        return concreteReporter.fileExtension()
    }
    
    func defaultFileName() -> String {
        return concreteReporter.defaultFileName()
    }
    
    func coordinator() -> WritingCoordinator {
        return concreteReporter.coordinator()
    }
    
}

/**
 Initialize the reporter type with a string
 
 If the string is different from "JSON", "PMD" and "XCODE", by default the type will be Plain
 
 :param: string The uppercase string with the name of the reporter type
 * JSON
 * PMD
 * PLAIN
 * XCODE
 */

func reporterWithName(string: String) -> Reporting {
    switch string.uppercaseString {
    case "JSON": return JSONReporter()
    case "PMD": return PMDReporter()
    case "XCODE": return XcodeReporter()
    default: return PlainReporter()
    }
}
