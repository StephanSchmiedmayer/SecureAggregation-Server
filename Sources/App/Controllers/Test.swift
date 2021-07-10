//
//  File.swift
//  
//
//  Created by stephan on 09.07.21.
//

import Foundation

class Test {
    static var shared = Test()
    
    private var internalCount: Int = 0
    
    /// Count gets incrementet on every access
    public var count: Int {
        internalCount += 1
        return internalCount - 1
    }
}
