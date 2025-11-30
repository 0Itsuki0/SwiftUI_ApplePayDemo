//
//  Cart.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import Foundation

struct Cart {
    var products: [ProductItem] = ProductItem.productsAvailable
    var shipping: ShippingMethod = .standardShipping
    var coupon: Coupon? = nil
}
