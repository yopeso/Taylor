//
//  Timer.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

final class Timer {
    var startDate: Date?
    
    init() {}
    
    func start() {
        startDate = Date()
    }
    
    func stop() -> TimeInterval {
        guard let startDate = self.startDate else { return 0 }
        
        let timeInterval = Date().timeIntervalSince(startDate)
        self.startDate = nil
        return timeInterval
    }
    
    func profile(_ block: () -> ()) -> TimeInterval {
        start()
        block()
        return stop()
    }
}
