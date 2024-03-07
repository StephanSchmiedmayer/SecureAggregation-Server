//
//  File 2.swift
//  
//
//  Created by Stephan Schmiedmayer on 07.03.24.
//

import Vapor
import SecureAggregationCore

class AutomaticSAController {
    typealias Value = SAInt
    
    static let threshold = 3
    static let start_user_count = 5
    static let modulus = Int.max / 4
    static let salt = "HP".data(using: .utf8)!
    private var timer: Timer?
    
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
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func advanceRound() throws {
        switch model.state {
        case .aborted, .waiting, .login:
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
    }
    
    func login(_ req: Request) throws -> UserID {
        let userCount = try model.loginClient()
        if userCount >= Self.start_user_count {
            try model.advanceToSetup()
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                self?.advanceRound()            }

            timer = Timer.scheduledTimer(timeInterval: 2, invocation: <#T##NSInvocation#>, repeats: <#T##Bool#>)
        }
        return userCount
    }

}
