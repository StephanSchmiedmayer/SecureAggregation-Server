//
//  File.swift
//  
//
//  Created by stephan on 15.08.21.
//

import Vapor
import SecureAggregationCore

let basicSecureAggregation = BasicSecureAggregationController()

/// Basic implementation of Secure Aggregation Controller, used by `BasicSecureAggregationRoutes`. Handles all network-related handling.
///
/// Most basic implementation possible of Controller: only forwadas to and from model, with no interpretation, no helping client when to send the next message etc.
/// Uses SAInt
class BasicSecureAggregationController {
    typealias Value = SAInt
    
    private(set) var model = SecureAggregationModel<SAInt>(threshold: 5, modulus: 100, salt: "LeagueOfLegends".data(using: .utf8)!)
    
    fileprivate init() {}
    
    /// Resets the class and starts a new execution of the SecureAggregation Protocol
    func start(_ req: Request) throws -> HTTPResponseStatus {
        model = SecureAggregationModel(threshold: 5, modulus: 100, salt: "LeagueOfLegends".data(using: .utf8)!)
        try model.start()
        return .ok
    }

    // MARK: - Login
    /// Registers the User as willing to pariticpate in a zycle of SecureAggregation and returns his ID
    func login(_ req: Request) throws -> UserID {
        return try model.loginClient()
    }

    /// Advance from Login to setup
    func finishLogin(_ req: Request) throws -> HTTPResponseStatus {
        try model.advanceToSetup()
        return .ok
    }

    // MARK: - Setup
    func setup(_ req: Request) throws -> SAConfiguration<Value> {
        return try model.setup()
    }

    func finishSetup(_ req: Request) throws -> HTTPResponseStatus {
        try model.advanceToRound0()
        return .ok
    }

    // MARK: - Round0
    func round0ClientMessage(_ req: Request) throws -> HTTPResponseStatus {
        let clientMessage = try req.content.decode(Network.Round0.ClientData.self)
        try model.addRound0Message(clientMessage.unwrap())
        return .ok
    }
    
    func finishRound0Collection(_ req: Request) throws -> HTTPResponseStatus {
        try model.finishRound0Collection()
        return .ok
    }
    
    func round0ServerResponse(_ req: Request) throws -> Network.Round0.ServerData {
        return try Network.Round0.ServerData(model.getRound0FinishedMessage())
    }
    
    // MARK: - Round1
    func advanceToRound1(_ req: Request) throws -> HTTPResponseStatus {
        try model.advanceToRound1()
        return .ok
    }
    
    func round1ClientMessage(_ req: Request) throws -> HTTPResponseStatus {
        let clientMessage = try req.content.decode(Network.Round1.ClientData.self)
        try model.addRound1Message(clientMessage.unwrap())
        return .ok
    }
    
    func finishRound1Collection(_ req: Request) throws -> HTTPResponseStatus {
        try model.finishRound1Collection()
        return .ok
    }
    
    func round1ServerResponse(_ req: Request) throws -> Network.Round1.ServerData {
        let userID = try req.content.decode(UserID.self)
        return try Network.Round1.ServerData(try model.getRound1FinishedMessage(userID: userID))
    }
    
    // MARK: - Round2
    func advanceToRound2(_ req: Request) throws -> HTTPResponseStatus {
        try model.advanceToRound2()
        return .ok
    }
    
    func round2ClientMessage(_ req: Request) throws -> HTTPResponseStatus {
        let clientMessage = try req.content.decode(Network.Round2.ClientData<Value>.self)
        try model.addRound2Message(clientMessage.unwrap())
        return .ok
    }
    
    func finishRound2Collection(_ req: Request) throws -> HTTPResponseStatus {
        try model.finishRound2Collection()
        return .ok
    }
    
    func round2ServerResponse(_ req: Request) throws -> Network.Round2.ServerData {
        return try Network.Round2.ServerData(try model.getRound2FinishedMessage())
    }
    
    // MARK: - Round4
    func advanceToRound4(_ req: Request) throws -> HTTPResponseStatus {
        try model.advanceToRound4()
        return .ok
    }
    
    func round4ClientMessage(_ req: Request) throws -> HTTPResponseStatus {
        let clientMessage = try req.content.decode(Network.Round4.ClientData<Value>.self)
        try model.addRound4Message(clientMessage.unwrap())
        return .ok
    }
    
    func finishRound4Collection(_ req: Request) throws -> HTTPResponseStatus {
        try model.finishRound4Collection()
        return .ok
    }
    
    func round4ServerResponse(_ req: Request) throws -> Network.Round4.ServerData<Value> {
        return try Network.Round4.ServerData(try model.getRound4FinishedMessage())
    }
}

