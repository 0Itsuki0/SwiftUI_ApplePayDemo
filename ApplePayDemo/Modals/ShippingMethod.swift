//
//  ShippingMethod.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//


import PassKit
import Foundation


struct ShippingMethod: Identifiable, Equatable {
    let id: String
    let label: String
    let amount: NSDecimalNumber
    let detail: String
    let deliveryDay: Int?
    
    var paymentMethod: PKShippingMethod {
        let shipping = PKShippingMethod(label: self.label, amount: self.amount.twoDecimal, type: .final)
        shipping.detail = self.detail
        shipping.identifier = self.id
        if let deliveryDay {
            let start = Date()
            let end = Date().addingTimeInterval(Double(deliveryDay) * 24 * 60 * 60)
            shipping.dateComponentsRange = PKDateComponentsRange(start: start.dateComponents, end: end.dateComponents)
        }
        return shipping
    }
}

extension ShippingMethod {
    static let expressShipping: ShippingMethod = ShippingMethod(id: "EXPRESS", label: "Itsuki's Express", amount: 9.99, detail: "Get your items immediately!", deliveryDay: 0)
    
    static let standardShipping: ShippingMethod = ShippingMethod(id: "STANDARD", label: "Itsuki's standard", amount: 0.00, detail: "Your order will get delivered to you some time in the future!", deliveryDay: nil)

    static let shippingAvailable: [ShippingMethod] = [expressShipping, standardShipping]
}
