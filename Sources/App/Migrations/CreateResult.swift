//
//  File.swift
//  
//
//  Created by stephan on 15.08.21.
//

import Vapor
import Fluent

struct CreateResult: Migration {
    // Called when running migration
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            // define table name of model, must match schema from model:
            .schema("results")
            .id() // define id column
            // define column, match type & required to type of model, name must match key of property wrapper (!= property name)
            .field("average", .double, .required)
            .field("clientsThatFinishedCount", .int, .required)
            .create() // create table in database
    }
    
    // Called when reverting Migration
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("results") // reference table with schema
            .delete() // delete table
    }
}
