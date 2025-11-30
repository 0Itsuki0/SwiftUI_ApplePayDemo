//
//  PaymentSuccessView.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import SwiftUI

struct PaymentSuccessView: View {
    @State private var paymentManager = PaymentManager()

    var body: some View {
        VStack(spacing: 24) {
            Text("Thank you!")
                .font(.title)
                .fontWeight(.bold)

            Text(self.paymentManager.cart.shipping.detail)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Spacer()
                .frame(height: 24)
            
            Image(systemName: "fireworks")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow, .red)
                .padding(.horizontal, 64)
        }
        .padding(.horizontal, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.yellow.opacity(0.1))
        .navigationTitle("Payment Confirmed")
        .navigationBarTitleDisplayMode(.large)
    }
}
