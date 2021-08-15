//
//  File.swift
//  
//
//  Created by stephan on 15.08.21.
//

import Vapor
import Fluent

struct CreateResult: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("results")
            .id()
            .field("average", .double, .required)
            .field("clientsThatFinishedCount", .int, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("results").delete()
    }
}
