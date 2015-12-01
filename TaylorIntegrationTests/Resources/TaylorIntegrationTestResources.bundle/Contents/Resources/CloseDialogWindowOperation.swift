//
//  CloseDialogWindowOperation.swift
//  Swetler
//
//  Created by Seremet Mihai on 10/15/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

public final class CloseDialogWindowOperation: NSOperation {
    
    let timeout = 3.0
    let scriptContent = "tell application \"System Events\" click button \"Open\" of window \"Open\" of application process \"ObjClean\" end tell"
    
    public override func main() {
        tryToCloseTheDialogWindow()
    }
    
    private func tryToCloseTheDialogWindow() {
        let bundle = NSBundle(forClass: self.dynamicType)
        if let path = bundle.pathForResource("CloseObjCleanDialogWindow", ofType: "scpt") {
            executeScript(path)
        }
    }
    
    
    private func executeScript(scriptPath: String) {
        let startTime = NSDate.timeIntervalSinceReferenceDate()
        var dictionary : NSDictionary?
        let script = NSAppleScript(contentsOfURL: NSURL(fileURLWithPath: scriptPath), error: &dictionary)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            repeat {
                script!.executeAndReturnError(&dictionary)
            } while NSDate.timeIntervalSinceReferenceDate() - startTime < self.timeout
        }
    }
    
}