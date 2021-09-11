//
//  File.swift
//  
//
//  Created by stephan on 15.08.21.
//

import Foundation
import SecureAggregationCore
import Vapor

enum SecureAggregationRoundState<Value: SAWrappedValue> {
    case aborted
    case waiting
    case login(_: LoginBuilderState)
    case setup(_: SetupState)
    case round0(_: Round0BuilderState)
    case round0Finished(_: Round0FinishedState)
    case round1(_: Round1BuilderState)
    case round1Finished(_: Round1FinishedState)
    case round2(_: Round2BuilderState<Value>)
    case round2Finished(_: Round2FinishedState<Value>)
//    case round3 (all red parts skipped for now)
    case round4(_:Round4BuilderState<Value>)
    case finished(_: FinishedState<Value>)
}

class LoginBuilderState {
    private(set) var userCount: Int = 0
    
    init() {}
    
    func incrementUserCount() -> Int {
        let result = userCount
        userCount += 1
        return result
    }
}

class SetupState {
    let U0: [UserID]
    
    init(previousState loginState: LoginBuilderState) {
        self.U0 = Array<UserID>(0..<loginState.userCount)
    }
    
    init(copyConstruxtor other: SetupState) {
        self.U0 = other.U0
    }
}

class Round0BuilderState {
    let previousState: SetupState
    
    /// All messages recieved by the server
    private(set) var collectedMessages: [Model.Round0.PublicKeysOfUser] = []
    
    init(_ setupState: SetupState) {
        self.previousState = setupState
    }
    
    func addMessage(_ message: Model.Round0.PublicKeysOfUser) {
        collectedMessages.append(message)
    }
}

class Round0FinishedState: SetupState {
    /// All messages collected by the server
    let publicKeys: [Model.Round0.PublicKeysOfUser]
    
    var U1: [UserID] {
        publicKeys.map { $0.userID }
    }
    
    init(previousState round0BuilderState: Round0BuilderState) {
        publicKeys = round0BuilderState.collectedMessages
        super.init(copyConstruxtor: round0BuilderState.previousState)
    }
    
    init(copyConstructor other: Round0FinishedState) {
        self.publicKeys = other.publicKeys
        super.init(copyConstruxtor: other)
    }
}

class Round1BuilderState {
    let previousState: Round0FinishedState
    
    private(set) var collectedMessages: [Model.EncryptedShare] = []
    
    init(previousState: Round0FinishedState) {
        self.previousState = previousState
    }

    func addMessage(_ message: [Model.EncryptedShare]) {
        self.collectedMessages.append(contentsOf: message)
    }
}

class Round1FinishedState: Round0FinishedState {
    let encryptedShares: [Model.EncryptedShare]
    
    var U2: [UserID] {
        encryptedShares.map { $0.u }
    }
    
    init(previousState: Round1BuilderState) {
        self.encryptedShares = previousState.collectedMessages
        super.init(copyConstructor: previousState.previousState)
    }
    
    init(copyConstructor other: Round1FinishedState) {
        self.encryptedShares = other.encryptedShares
        super.init(copyConstructor: other)
    }
}

class Round2BuilderState<Value: SAWrappedValue> {
    let previousState: Round1FinishedState
    
    private(set) var collectedMaskedValues: [Model.MaskedValueFromUser<Value>] = []
    
    init(previousState: Round1FinishedState) {
        self.previousState = previousState
    }
    
    func addMaksedValue(_ newValue: Model.MaskedValueFromUser<Value>) {
        collectedMaskedValues.append(newValue)
    }
}

class Round2FinishedState<Value: SAWrappedValue>: Round1FinishedState {
    let collectedMaskedValues: [Model.MaskedValueFromUser<Value>]
    var U3: [UserID] {
        collectedMaskedValues.map { $0.origin }
    }
    
    init(previousState: Round2BuilderState<Value>) {
        self.collectedMaskedValues = previousState.collectedMaskedValues
        super.init(copyConstructor: previousState.previousState)
    }
    
    init(copyConstructor other: Round2FinishedState<Value>) {
        self.collectedMaskedValues = other.collectedMaskedValues
        super.init(copyConstructor: other)
    }
}

class Round4BuilderState<Value: SAWrappedValue> {
    let previousState: Round2FinishedState<Value>
    
    private(set) var s_uv: [Model.AdressedShare] = []
    private(set) var b_uv: [Model.AdressedShare] = []
    
    init(previousState: Round2FinishedState<Value>) {
        self.previousState = previousState
    }
    
    func addMessage(s_uv_newValue: [Model.AdressedShare], b_uv_newValue: [Model.AdressedShare]) {
        self.s_uv.append(contentsOf: s_uv_newValue)
        self.b_uv.append(contentsOf: b_uv_newValue)
    }
}

/// Not actually used as a state but as a convenience during getRound4FinishedMessage
class Round4State<Value: SAWrappedValue>: Round2FinishedState<Value> {
    let s_uv: [Model.AdressedShare]
    let b_uv: [Model.AdressedShare]
    
    init(previousState: Round4BuilderState<Value>) {
        self.s_uv = previousState.s_uv
        self.b_uv = previousState.b_uv
        super.init(copyConstructor: previousState.previousState)
    }
}

class FinishedState<Value: SAWrappedValue> {
    let value: Value
    
    init(value: Value) {
        self.value = value
    }
}
