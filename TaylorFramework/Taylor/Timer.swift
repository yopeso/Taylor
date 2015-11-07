//
//  Timer.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

class Timer {
    var startDate: NSDate?
    
    init() {}
    
    func start() {
        startDate = NSDate()
    }
    
    func stop() -> NSTimeInterval {
        guard let startDate = self.startDate else { return 0 }
        
        let timeInterval = NSDate().timeIntervalSinceDate(startDate)
        self.startDate = nil
        return timeInterval
    }
    
    func profile(block: () -> ()) -> NSTimeInterval {
        start()
        block()
        return stop()
    }
}