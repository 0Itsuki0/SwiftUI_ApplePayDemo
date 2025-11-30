//
//  ProductItem.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import PassKit
import Foundation


struct ProductItem: Identifiable, Equatable {
    let id: String
    let label: String
    let amount: NSDecimalNumber
    var quantity: UInt = 0
         
    var grandTotal: NSDecimalNumber {
        return self.amount.multiplying(by: NSDecimalNumber(value: quantity))
    }
    
    var paymentSummaryItem: PKPaymentSummaryItem {
        PKPaymentSummaryItem(label: "\(self.label) * \(self.quantity)", amount: self.grandTotal.twoDecimal, type: .final)
    }
}

extension ProductItem {
    static let hello = ProductItem(id: "HELLO", label: "Hello From Itsuki", amount: 9.99)
    static let like = ProductItem(id: "LIKE", label: "Like From Itsuki", amount: 999.99)
    static let love = ProductItem(id: "LOVE", label: "Love From Itsuki", amount: 99999.99)

    static let productsAvailable: [ProductItem] = [hello, like, love]
}
