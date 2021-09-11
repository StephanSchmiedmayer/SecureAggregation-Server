//
//  File.swift
//  
//
//  Created by stephan on 11.09.21.
//

import Foundation
import SecureAggregationCore

extension Array where Element: SAWrappedValue {
    /// Summs all `SAWrappedValues` with the given modulus according so `Element.add`
    func sum(mod: Element.Modulus) -> Element {
        self.reduce(Element.zero) { aggregate, newValue in
            aggregate.add(newValue, mod: mod)
        }
    }
}
