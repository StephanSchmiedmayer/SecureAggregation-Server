//
//  File.swift
//  
//
//  Created by stephan on 06.10.21.
//

import Foundation
import XCTest
@testable import SecureAggregationCore
import CryptoKit

final class ServerMaskTest: XCTestCase {
    let modulus = 1000
    typealias Value = SAInt
    
    func testCreatePrivateKeyAndSAInt() throws {
        let privateKey = SAPubKeyCurve.KeyAgreement.PrivateKey()
        print(privateKey.rawRepresentation.base64EncodedString())
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: privateKey.publicKey)
//        print(Value.mask(forKey: sharedSecret, mod: self.modulus))
    }
}
