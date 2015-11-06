//
//  Timer.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

public class Timer {
    var startDate: NSDate?
    
    public init() {}
    
    public func start() {
        startDate = NSDate()
    }
    
    public func stop() -> NSTimeInterval {
        guard let startDate = self.startDate else { return 0 }
        
        let timeInterval = NSDate().timeIntervalSinceDate(startDate)
        self.startDate = nil
        return timeInterval
    }
    
    public func profile(block: () -> ()) -> NSTimeInterval {
        start()
        block()
        return stop()
    }
}