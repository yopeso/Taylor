//
//  Array+Extensions.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

extension Array {
    /**
    Return an `Array` containing the results of mapping `transform` over `self`.
    
    The `transform` operation is parralelized to take advantage of all the
    proccessor cores.
    */
    func pmap<T>(transform: (Element -> T)) -> [T] {
        guard !self.isEmpty else { return [] }
        
        var result: [(Int, [T])] = []
        
        let group = dispatch_group_create()
        let lock = dispatch_queue_create("com.queue.swift.extensions.pmap", DISPATCH_QUEUE_SERIAL)
        
        let step: Int = max(1, self.count / NSProcessInfo.processInfo().activeProcessorCount) // step can never be 0
        
        0.stride(to: self.count, by: 1).forEach { stepIndex in
            let capturedStepIndex = stepIndex
            
            var stepResult: [T] = []
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                for i in (capturedStepIndex * step)..<((capturedStepIndex + 1) * step) {
                    if i < self.count {
                        let mappedElement = transform(self[i])
                        stepResult += [mappedElement]
                    }
                }
                
                dispatch_group_async(group, lock) { result += [(capturedStepIndex, stepResult)] }
            }
        }
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        
        return result.sort { $0.0 < $1.0 }.flatMap { $0.1 }
    }
}

func +<T>(lhs: [T], rhs: T) -> [T] {
    return lhs + [rhs]
}
