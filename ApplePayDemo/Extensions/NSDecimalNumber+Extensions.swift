//
//  PKPaymentSummaryItem.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import Foundation

extension NSDecimalNumber {
    var twoDecimal: NSDecimalNumber {
        // For USD (other currencies may have different requirements), the amount within any PKPaymentSummaryItem has to have less than or equal to 2 significant digits.
        // Otherwise, we will get the following error.
        // Payment request is invalid: Error Domain=PKPassKitErrorDomain Code=1 "Invalid in-app payment request" UserInfo={NSLocalizedDescription=Invalid in-app payment request, NSUnderlyingError=0x600000c17db0 {Error Domain=PKPassKitErrorDomain Code=1 "PKPaymentRequest must contain an NSArray property 'paymentSummaryItems' of valid objects of class PKPaymentSummaryItem" UserInfo={NSLocalizedDescription=PKPaymentRequest must contain an NSArray property 'paymentSummaryItems' of valid objects of class PKPaymentSummaryItem, NSUnderlyingError=0x600000c14db0 {Error Domain=PKPassKitErrorDomain Code=1 "PKPaymentSummaryItem has an invalid label or amount property" UserInfo={NSLocalizedDescription=PKPaymentSummaryItem has an invalid label or amount property, NSUnderlyingError=0x600000c162b0 {Error Domain=PKPassKitErrorDomain Code=1 "Amount is not valid for specified currency. Amount: 0.999, Currency: USD" UserInfo=0x600000295b80 (not displayed)}}}}}}
        return NSDecimalNumber(string: String(format: "%.2f", self.doubleValue))
    }
}
