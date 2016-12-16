//
//  ParallelizedMap.swift
//  Taylor
//
//  Created by Andrei Raifura on 12/16/16.
//  Copyright © 2016 YOPESO. All rights reserved.
//

import Dispatch
import class Foundation.ProcessInfo

extension Collection where Index == Int, IndexDistance == Int {
    /**
     Return an `Array` containing the results of mapping `transform` over `self`.
     
     The `transform` operation is parralelized to take advantage of multiple
     proccessor cores.
     */
    func pmap<T>(
        channels: Int = ProcessInfo.processInfo.activeProcessorCount,
        transform: @escaping ((Iterator.Element) -> T)) -> [T] {
        if count < 2 { return map(transform) } // nothing to parralelize
        
        typealias IndexedStepResult = (Int, [T])
        var result: [IndexedStepResult] = []
        
        let group = DispatchGroup()
        let lock = DispatchQueue(label: "com.queue.swift.extensions.pmap")
        
        let step = Swift.max(1, count / channels) // step can never be 0
        
        for channel in 0...channels {
            DispatchQueue.global().async(group: group) {
                let range = channel * step..<(channel + 1) * step
                let stepResult = self.map(range: range, transform: transform)
                
                lock.async(group: group) { result += [(channel, stepResult)] }
            }
        }
        
        _ = group.wait(timeout: .distantFuture)
        
        return result.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
    }
    
    /**
     Maps the elements associated to indexes in the given range.
     
     - parameter range: The range of indexes for elements to be transformed. 
     
     - parameter transform: A mapping closure. transform accepts an element
     of this sequence as its parameter and returns a transformed value of
     the same or of a different type.
     
     - returns: An array of transformed elements
     */
    private func map<T>(
        range: CountableRange<Index>,
        transform: @escaping ((Iterator.Element) -> T)) -> [T] {
        
        let range = safeIndexRange(for: range)
        
        return range.reduce([T]()) { result, index in
            return result + [transform(self[index])]
        }
    }
    
    /**
     Takes an Range of indexes and returns a range of valid indexes for the
     collection.
     */
    private func safeIndexRange(for range: CountableRange<Index>) -> CountableRange<Index> {
        guard range.lowerBound < count else { return 0 ..< 0 }
        guard range.upperBound <= count else { return range.lowerBound ..< count }
        
        return range
    }
}
