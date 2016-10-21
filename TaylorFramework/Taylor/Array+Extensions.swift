//
//  Array+Extensions.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Cocoa

extension Array {
    /**
    Return an `Array` containing the results of mapping `transform` over `self`.
    
    The `transform` operation is parralelized to take advantage of all the
    proccessor cores.
    */
    func pmap<T>(_ transform: @escaping ((Element) -> T)) -> [T] {
        guard !self.isEmpty else { return [] }
        
        var result: [(Int, [T])] = []
        
        let group = DispatchGroup()
        let lock = DispatchQueue(label: "com.queue.swift.extensions.pmap", attributes: [])
        
        let step = Swift.max(1, self.count / ProcessInfo.processInfo.activeProcessorCount) // step can never be 0
        
        stride(from: 0, to: self.count, by: 1).forEach { stepIndex in
            let capturedStepIndex = stepIndex
            
            var stepResult: [T] = []
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(group: group) {
                for i in (capturedStepIndex * step)..<((capturedStepIndex + 1) * step) {
                    if i < self.count {
                        let mappedElement = transform(self[i])
                        stepResult += [mappedElement]
                    }
                }
                
                lock.async(group: group) { result += [(capturedStepIndex, stepResult)] }
            }
        }
        
        _ = group.wait(timeout: DispatchTime.distantFuture)
        
        return result.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
    }
}

func +<T>(lhs: [T], rhs: T) -> [T] {
    return lhs + [rhs]
}
