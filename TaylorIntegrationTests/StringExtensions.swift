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
        let components = self.componentsSeparatedByString("/")
        if components.count == 0 || components.count == 1 {
            return self
        }
        
        return components[0..<components.count - 1].joinWithSeparator("/")
    }

    public var fileExtension : String {
        let components = self.componentsSeparatedByString(".")
        if let lastComponent = components.last where components.count > 1 {
            return lastComponent
        }
        
        return ""
    }


    public var stringByTrimmingTheExtension : String {
        let components = self.componentsSeparatedByString(".")
        if components.count > 2 {
            return components[0..<components.count - 1].joinWithSeparator(".")
        }
        
        return components.first!
    }
    
    
    public func stringByAppendingPathComponent(component: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(component)
    }
    
    
    public var lastPathComponent : String {
        return (self as NSString).lastPathComponent
    }

}