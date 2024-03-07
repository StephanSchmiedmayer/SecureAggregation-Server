//
//  File 2.swift
//  
//
//  Created by Stephan Schmiedmayer on 07.03.24.
//

import Vapor
import SecureAggregationCore
import Logging
import NIO

let logger = Logger(label: "de.schmiedmayer.stephan.SecureAggregationServer")

let automaticSAController = AutomaticSAController()

class AutomaticSAController {
    typealias Value = SAInt
    
    static let threshold = 3
    static let start_user_count = 4
    static let modulus = Int.max / 4
    static let salt = "HP".data(using: .utf8)!
    private var timer: RepeatedTask?
    
    private(set) var model: SecureAggregationModel<Value>
    
    fileprivate init() {
        try! model = AutomaticSAController.getNewModel()
    }
    
    private static func getNewModel() throws -> SecureAggregationModel<Value> {
        let newModel = SecureAggregationModel<Value>(threshold: AutomaticSAController.threshold, modulus: AutomaticSAController.modulus, salt: AutomaticSAController.salt)
        try newModel.start()
        return newModel
    }
    
    func restart(_ req: Request) throws -> HTTPResponseStatus {
        try model = AutomaticSAController.getNewModel()
        return .ok
    }
    
    private func startTimer(_ req: Request) {
        logger.info("Start timer")
        let eventLoop = req.eventLoop
        self.timer = eventLoop.scheduleRepeatedTask(initialDelay: .seconds(2), delay: .seconds(2)) { task in
            logger.info("Timer fired")
            try? self.advanceRound()
        }
    }
    
    private func stopTimer() {
        logger.info("Stopping timer.")
        self.timer?.cancel()
        self.timer = nil
    }
    
    func advanceRound() throws {
        switch model.state {
        case .aborted, .waiting, .login:
            logger.warning("Timer in unexpected state. Stopping timer.")
            stopTimer()
            try model.start()
        case .setup:
            try model.advanceToRound0()
        case .round0:
            try model.finishRound0Collection()
        case .round0Finished:
            try model.advanceToRound1()
        case .round1:
            try model.finishRound1Collection()
        case .round1Finished:
            try model.advanceToRound2()
        case .round2:
            try model.finishRound2Collection()
        case .round2Finished:
            try model.advanceToRound4()
        case .round4:
            try model.finishRound4Collection()
        case .finished:
            stopTimer()
        }
        logger.info("Automatically advanced state to \(model.state)")
    }
    
    func getState(_ req: Request) throws -> String {
        switch model.state {
        case .aborted:
            return "aborted"
        case .waiting:
            return "waiting"
        case .login:
            return "login"
        case .setup:
            return "setup"
        case .round0:
            return "round0"
        case .round0Finished:
            return "rount0Finished"
        case .round1:
            return "round1"
        case .round1Finished:
            return "round1Finished"
        case .round2:
            return "round2"
        case .round2Finished:
            return "round2Finished"
        case .round4:
            return "round4"
        case .finished:
            return "finished"
        }
    }
    
    func login(_ req: Request) throws -> UserID {
        let userIndex = try model.loginClient()
        logger.info("New user \(userIndex)")
        if userIndex + 1 >= Self.start_user_count {
            try model.advanceToSetup()
            startTimer(req)
        }
        return userIndex
    }
    
    func setup(_ req: Request) throws -> SAConfiguration<Value> {
        return try model.setup()
    }
    
    // MARK: - Round0
    func round0ClientMessage(_ req: Request) throws -> HTTPResponseStatus {
        let clientMessage = try req.content.decode(Network.Round0.ClientData.self)
        try model.addRound0Message(clientMessage.unwrap())
        return .ok
    }
        
    func round0ServerResponse(_ req: Request) throws -> Network.Round0.ServerData {
        return try Network.Round0.ServerData(model.getRound0FinishedMessage())
    }
    
    // MARK: - Round1
    func round1ClientMessage(_ req: Request) throws -> HTTPResponseStatus {
        let clientMessage = try req.content.decode(Network.Round1.ClientData.self)
        try model.addRound1Message(clientMessage.unwrap())
        return .ok
    }
        
    func round1ServerResponse(_ req: Request) throws -> Network.Round1.ServerData {
        let clientMessage = try req.content.decode(Network.Round1.ClientDataNeededForServerData.self)
        return try Network.Round1.ServerData(try model.getRound1FinishedMessage(userID: clientMessage.unwrap()))
    }
    
    // MARK: - Round2
    func round2ClientMessage(_ req: Request) throws -> HTTPResponseStatus {
        let clientMessage = try req.content.decode(Network.Round2.ClientData<Value>.self)
        try model.addRound2Message(clientMessage.unwrap())
        return .ok
    }
        
    func round2ServerResponse(_ req: Request) throws -> Network.Round2.ServerData {
        return Network.Round2.ServerData(try model.getRound2FinishedMessage())
    }
    
    // MARK: - Round4
    func round4ClientMessage(_ req: Request) throws -> HTTPResponseStatus {
        let clientMessage = try req.content.decode(Network.Round4.ClientData<Value>.self)
        try model.addRound4Message(clientMessage.unwrap())
        return .ok
    }
        
    func round4ServerResponse(_ req: Request) throws -> Network.Round4.ServerData<Value> {
        return Network.Round4.ServerData(try model.getRound4FinishedMessage())
    }
}
