//
//  PaymentAuthorizationView.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//


import SwiftUI
import PassKit

struct PaymentAuthorizationView: UIViewControllerRepresentable {
    let controller: PKPaymentAuthorizationViewController
    
    @Environment(PaymentManager.self) private var paymentManager

    func makeUIViewController(context: Context) -> PKPaymentAuthorizationViewController {
        self.controller.delegate = self.paymentManager
        return self.controller
    }

 
    func updateUIViewController(_ uiViewController: PKPaymentAuthorizationViewController, context: Context) {}
}
