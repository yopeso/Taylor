//
//  JSONToViolationParser.swift
//  Swetler
//
//  Created by Seremet Mihai on 11/3/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation
import TaylorFramework

class JSONToViolationParser {
    
    func parseFile(_ filePath: String) -> [[String:AnyObject]] {
        guard filePath.lastPathComponent.fileExtension == "json" else { return [] }
        return getViolationDictionariesFromFile(filePath)
    }
    
    
    fileprivate func getViolationDictionariesFromFile(_ filePath: String) -> [[String:AnyObject]] {
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        guard let data = jsonData else { return [] }
        var jsonResult : NSDictionary? = nil
        do {
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        }
        catch {
            print("Error while creating the JSON object.")
        }
        guard let result = jsonResult else { return [] }
        if let violations = result["violation"] as? [[String:AnyObject]] { return violations }
        
        return []
    }
    
}
