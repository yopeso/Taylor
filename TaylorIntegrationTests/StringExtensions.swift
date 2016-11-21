//
//  StringExtensions.swift
//  Taylor
//
//  Created by Seremet Mihai on 11/9/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

extension String {
    
    public func stringWithoutLastComponent() -> String {
        let components = self.components(separatedBy: "/")
        if components.count == 0 || components.count == 1 {
            return self
        }
        
        return components[0..<components.count - 1].joined(separator: "/")
    }

    public var fileExtension : String {
        let components = self.components(separatedBy: ".")
        if let lastComponent = components.last , components.count > 1 {
            return lastComponent
        }
        
        return ""
    }


    public var stringByTrimmingTheExtension : String {
        let components = self.components(separatedBy: ".")
        if components.count > 2 {
            return components[0..<components.count - 1].joined(separator: ".")
        }
        
        return components.first!
    }
    
    
    public func stringByAppendingPathComponent(_ component: String) -> String {
        return (self as NSString).appendingPathComponent(component)
    }
    
    
    public var lastPathComponent : String {
        return (self as NSString).lastPathComponent
    }

}
