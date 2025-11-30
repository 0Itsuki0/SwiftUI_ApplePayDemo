//
//  Array.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import PassKit
import Foundation

extension Array<NSDecimalNumber> {
    var total: NSDecimalNumber {
        return NSDecimalNumber(decimal: self.map(\.decimalValue).reduce(0.0, +))
    }
}


extension Array<PKShippingMethod> {
    func sorted(currentSelected: PKShippingMethod) -> [PKShippingMethod] {
        return self.sorted(by: { one, _ in
            return one == currentSelected
        })
    }
}
