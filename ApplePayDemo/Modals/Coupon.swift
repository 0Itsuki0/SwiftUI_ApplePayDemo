//
//  Coupon.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import PassKit
import Foundation

struct Coupon: Identifiable, Equatable {
    var id: String {
        return self.code
    }
    
    let amountOff: NSDecimalNumber
    
    let code: String
    
    var label: String {
        return "Coupon: \(code)".localizedUppercase
    }
        
    func createPaymentSummaryItem(products: [ProductItem]) -> PKPaymentSummaryItem {
        let totalAmount = products.map(\.grandTotal).total
        let amountOff = totalAmount.multiplying(by: self.amountOff).multiplying(by: -1)
        return PKPaymentSummaryItem(label: self.label, amount: amountOff.twoDecimal, type: .final)
    }
    
}

extension Coupon {
    static let itsuki10 = Coupon(amountOff: 0.1, code: "ITSUKI10")
    static let itsuki20 = Coupon(amountOff: 0.2, code: "ITSUKI20")
    static let itsuki30 = Coupon(amountOff: 0.3, code: "ITSUKI30")

    static let couponAvailable: [Coupon] = [itsuki10, itsuki20, itsuki30]
}
