//
//  MerchantInformation.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import PassKit
import Foundation

final class MerchantInformation {
    // Merchant identifier:
    // Can be Created in the Certificates, Identifiers & Profiles section of Apple Developer account.
    static let merchantId = "merchant.com...."
    
    static let currencyCode = "USD"

    // Set this property to the two-letter ISO 3166 code for the country or region of the merchant’s principal place of business.
    static let merchantCountryCode = "US"
    
    static let supportedNetworks: [PKPaymentNetwork] = [
        .masterCard,
        .visa,
        .JCB,
        .suica,
        .nanaco,
    ]
}
