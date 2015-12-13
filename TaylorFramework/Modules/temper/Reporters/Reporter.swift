//
//  Reporter.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

protocol Reporter {
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


struct PlainReporter: Reporter {
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

struct PMDReporter: Reporter {
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

struct XcodeReporter: Reporter {
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

struct JSONReporter: Reporter {
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



/**
 Initialize the reporter with type and name
 
 :param: type The type of the reporter
 * JSON
 * PMD
 * Plain
 * Xcode
 
 :param: fileName The file name of the reporter
 */

func reporterWith(type type: String, fileName : String) -> Reporter {
    return reporterWithName(type)
}

/**
 Initialize the reporter with type and name
 
 For reporter file name will be used the default file name for reporter type:
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

func reporterWith(type type: String) -> Reporter {
    return reporterWithName(type)
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

func reporterWithName(string: String) -> Reporter {
    switch string.uppercaseString {
    case "JSON": return JSONReporter()
    case "PMD": return PMDReporter()
    case "XCODE": return XcodeReporter()
    default: return PlainReporter()
    }
}