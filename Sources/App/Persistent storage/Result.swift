//
//  File.swift
//  
//
//  Created by stephan on 15.08.21.
//

import Vapor
import Fluent

/// Result of a secure aggregation round
final class Result: Model {
    static let schema = "results"
    
    @ID
    var id: UUID?
    
    @Field(key: "average")
    var average: Double
    
    @Field(key: "clientsThatFinishedCount")
    var clientThatFinisehdCount: Int
    
    init() {}
    
    init(id: UUID? = nil, average: Double, clientsThatFinishedCount: Int) {
        self.id = id
        self.average = average
        self.clientThatFinisehdCount = clientThatFinisehdCount
    }
}

extension Result: Content {}
