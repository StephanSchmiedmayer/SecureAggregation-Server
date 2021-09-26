//
//  File.swift
//  
//
//  Created by stephan on 15.08.21.
//

import Foundation
import SecureAggregationCore
import Vapor
import ShamirSecretShare

/// Model of Secure Aggregation. Independent of Controller. Handles the logic
class SecureAggregationModel<Value: SAWrappedValue> {
    private(set) var state: SecureAggregationRoundState<Value> = .waiting
    
    private let stateLock: Lock = Lock()
    
    private let threshold: Int
    private let modulus: Value.Modulus
    private let salt: Data
    
    
    init(threshold: Int, modulus: Value.Modulus, salt: Data) {
        self.threshold = threshold
        self.modulus = modulus
        self.salt = salt
    }
    
    func start() throws {
        try stateLock.withLock {
            try state.advance(to: .login(LoginBuilderState()))
        }
    }
    
    // MARK: - Login
        
    func loginClient() throws -> UserID  {
        return try stateLock.withLock {
            guard case .login(let loginBuilderState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            return loginBuilderState.incrementUserCount()
        }
    }
    
    // MARK: - Setup
    
    func advanceToSetup() throws {
        try stateLock.withLock {
            guard case .login(let loginState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            // Fixes the userCount
            try state.advance(to: .setup(SetupState(previousState: loginState)))
        }
    }
    
    func setup() throws -> SAConfiguration<Value> {
        try stateLock.withLock {
            guard case .setup(let setupState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            return SAConfiguration(numberOfUsers: setupState.U0.count,
                                   threshold: self.threshold,
                                   modulus: self.modulus,
                                   salt: self.salt)
        }
    }
    
    // MARK: - Round 0
    
    func advanceToRound0() throws {
        try stateLock.withLock {
            guard case .setup(let setupState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            try state.advance(to: .round0(Round0BuilderState(setupState)))
        }
    }
    
    func addRound0Message(_ message: Model.Round0.ClientData) throws {
        try stateLock.withLock {
            guard case .round0(let round0State) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            round0State.addMessage(message.publicKeyInformation)
        }
    }
    
    func finishRound0Collection() throws {
        try stateLock.withLock {
            guard case .round0(let round0State) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            try state.advance(to: .round0Finished(Round0FinishedState(previousState: round0State)))
        }
    }
    
    func getRound0FinishedMessage() throws -> Model.Round0.ServerData {
        return try stateLock.withLock {
            guard case .round0Finished(let round0FinishedState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            return Model.Round0.ServerData(collectedData: round0FinishedState.publicKeys)
        }
    }
    
    // MARK: - Round 1
    
    func advanceToRound1() throws {
        try stateLock.withLock {
            guard case .round0Finished(let round0FinishedState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            try state.advance(to: .round1(Round1BuilderState(previousState: round0FinishedState)))
        }
    }
    
    func addRound1Message(_ message: Model.Round1.ClientData) throws {
        try stateLock.withLock {
            guard case .round1(let round1BuilderState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            round1BuilderState.addMessage(message.encryptedShares)
        }
    }
    
    func finishRound1Collection() throws {
        try stateLock.withLock {
            guard case .round1(let round1BuilderState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            try state.advance(to: .round1Finished(Round1FinishedState(previousState: round1BuilderState)))
        }
    }
    
    func getRound1FinishedMessage(userID: UserID) throws -> Model.Round1.ServerData {
        try stateLock.withLock {
            guard case .round1Finished(let round1FinishedState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            return Model.Round1.ServerData(encryptedServerMessagesForMe: round1FinishedState.encryptedShares.filter({ encryptedShare in
                encryptedShare.v == userID
            }))
        }
    }
    
    // MARK: - Round 2
    
    func advanceToRound2() throws {
        try stateLock.withLock {
            guard case .round1Finished(let round1FinishedState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            try state.advance(to: .round2(Round2BuilderState<Value>(previousState: round1FinishedState)))
        }
    }
    
    func addRound2Message(_ message: Model.Round2.ClientData<Value>) throws {
        try stateLock.withLock {
            guard case .round2(let round2BuilderState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            round2BuilderState.addMaksedValue(message.wrappedValue)
        }
    }
    
    func finishRound2Collection() throws {
        try stateLock.withLock {
            guard case .round2(let round2BuilderState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            try state.advance(to: .round2Finished(Round2FinishedState<Value>(previousState: round2BuilderState)))
        }
    }
    
    func getRound2FinishedMessage() throws -> Model.Round2.ServerData {
        try stateLock.withLock {
            guard case .round2Finished(let round2FinishedState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            return Model.Round2.ServerData(remainingUsers: round2FinishedState.U2)
        }
    }
    
    // MARK: - Round4
    
    func advanceToRound4() throws {
        try stateLock.withLock{
            guard case .round2Finished(let round2FinishedState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            try state.advance(to: .round4(Round4BuilderState<Value>(previousState: round2FinishedState)))
        }
    }
    
    func addRound4Message(_ message: Model.Round4.ClientData) throws {
        try stateLock.withLock {
            guard case .round4(let round4BuilderState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            round4BuilderState.addMessage(s_uv_newValue: message.s_uv, b_uv_newValue: message.b_uv)
        }
    }
    
    func finishRound4Collection() throws {
        try stateLock.withLock {
            guard case .round4(let round4BuilderState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            // Calculate value
            let currentState = Round4State(previousState: round4BuilderState)
            let U2WithoutU3 = Set(currentState.U2).subtracting(Set(currentState.U3))// currentState.U2.filter { !currentState.U3.contains($0) }
            // try to reconstruct s_u_SK
            let p_vu_uElemU3_vElemU2WithoutU3_array = try U2WithoutU3.map { vID -> (SAPubKeyCurve.KeyAgreement.PrivateKey, UserID)  in
                let s_v_privateKey_shares = currentState.s_uv.filter {
                    $0.origin == vID
                }.map {
                    $0.share
                }
                let encoded_s_v_privateKey = try Secret.combine(shares: s_v_privateKey_shares)
                let s_v_privateKey = try SAPubKeyCurve.KeyAgreement.PrivateKey(rawRepresentation: encoded_s_v_privateKey)
                return (s_v_privateKey, vID)
            }.flatMap { s_v_privateKey, vID in
                // u elem U3, v elem U2\U3, p_uv = -p_vu:
                // y_u = x_u + p_uv (+...); x_u (+...) = y_u - p_uv = y_u + p_vu
                try currentState.U3.map { uID -> Value in
                    guard let s_u_publicKey = currentState.publicKeys.first(where: { $0.userID == uID })?.s_publicKey else {
                        throw SecureAggregationError.protocolAborted(reason: .unexpecedUserInProtocol)
                    }
                    let s_uv_sharedSecret = try s_v_privateKey.sharedSecretFromKeyAgreement(with: s_u_publicKey)
                    return Value.mask(forSeed: s_uv_sharedSecret, mod: self.modulus).cancelling(ownID: vID, otherID: uID, mod: self.modulus) // p_vu
                }
            }
            let p_u_masksForRemainingUsers = try currentState.U3.map { uID in
                currentState.b_uv.filter {
                    $0.origin == uID
                }.map {
                    $0.share
                }
            }.map { shares in
                try Secret.combine(shares: shares)
            }.map { privateKeyData in
                try SAPubKeyCurve.KeyAgreement.PrivateKey.init(rawRepresentation: privateKeyData)
            }.map { privateKey in
                try privateKey.sharedSecretFromKeyAgreement(with: privateKey.publicKey)
            }.map { secret in
                Value.mask(forSeed: secret, mod: self.modulus)
            }
            
            let sum_y_u_U3 = currentState.collectedMaskedValues.filter {
                currentState.U3.contains($0.origin)
            }.map {
                $0.maskedValue
            }.sum(mod: self.modulus)
            let sum_p_u_uElemU3 = p_u_masksForRemainingUsers.sum(mod: self.modulus)
            let sum_p_vu_uElemU3_vElemU2WithoutU3 = p_vu_uElemU3_vElemU2WithoutU3_array.sum(mod: self.modulus)
            
            let finalValue = sum_y_u_U3.sub(sum_p_u_uElemU3, mod: self.modulus).add(sum_p_vu_uElemU3_vElemU2WithoutU3, mod: self.modulus)
            try state.advance(to: .finished(FinishedState<Value>(value: finalValue)))
        }
    }
    
    func getRound4FinishedMessage() throws -> Model.Round4.ServerData<Value> {
        try stateLock.withLock {
            guard case .finished(let finishedState) = state else {
                throw SecureAggregationError.incorrectStateForMethod
            }
            return Model.Round4.ServerData(value: finishedState.value)
        }
    }
    
    // MARK: - Debug only
    func setState(to state: SecureAggregationRoundState<Value>) {
        self.state = state
    }
}
