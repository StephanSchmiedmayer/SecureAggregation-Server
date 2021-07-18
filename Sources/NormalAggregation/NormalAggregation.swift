//
//  File.swift
//  
//
//  Created by stephan on 13.07.21.
//

import Foundation

class NormalAggregation {
    // TODO: make thread-safe
    // TODO: make persistent
    static var shared = NormalAggregation()
    
    var values: [Int] = []
    
    var average: Double?
    
    func addValue(value: Int) {
        values.append(value)
    }
    
    func calculateAverage() {
        let count = values.count
        let sum = values.reduce(0, +)
        average = Double(sum) / Double(count)
    }
    
}
