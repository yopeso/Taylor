//
//  Reporter.swift
//  Temper
//
//  Created by Mihai Seremet on 9/4/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


public enum ReporterType {
    case JSON
    case PMD
    case Plain
    case Xcode
    
    /**
        Initialize the reporter type with a string
        
        If the string is different from "JSON", "PMD" and "XCODE", by default the type will be Plain
    
        :param: string The uppercase string with the name of the reporter type
        * JSON
        * PMD
        * PLAIN
        * XCODE
    */
    
    public init(string: String) {
        switch string.uppercaseString {
        case "JSON": self = .JSON
        case "PMD": self = .PMD
        case "XCODE": self = .Xcode
        default: self = .Plain
        }
    }
    
    /**
        This method return the file extension for reporter file
    
        For Xcode type it return "" because Xcode type don't have a file name
        
        :returns: String The file extension
    */
    
    public func fileExtension() -> String {
        switch self {
        case .JSON: return "json"
        case .PMD: return "pmd"
        case .Plain: return "txt"
        case .Xcode: return ""
        }
    }
    
    /**
        This method return the default reporter file the type
    
        For Xcode type it return "" because Xcode type don't have a file name
        
        :returns: String The file name of the reporter
    */
    
    public func defaultFileName() -> String {
        if self == .Xcode { return "" }
        return "taylor_report" + "." + fileExtension()
    }
}

public class Reporter {
    let type : ReporterType
    let fileName : String
    
    /**
        Initialize the reporter with type and name
    
        :param: type The type of the reporter
        * JSON
        * PMD
        * Plain
        * Xcode
        
        :param: fileName The file name of the reporter
    */
    
    public init(type : ReporterType, fileName : String) {
        self.type = type
        self.fileName = fileName
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
    
    convenience public init (type : ReporterType) {
        self.init(type: type, fileName:type.defaultFileName())
    }
}