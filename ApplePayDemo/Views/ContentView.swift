//
//  ContentView.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import SwiftUI
import PassKit

struct ContentView: View {
    @State private var paymentManager = PaymentManager()
    
    @State private var couponEntry: String = ""
    @State private var couponEntryError: String? = nil

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Shopping Cart")
                        .font(.title2)
                        .fontWeight(.bold)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.horizontal, 0)
                }
                
                Section("Products") {
                    ForEach($paymentManager.cart.products) { $product in
                        
                        HStack(spacing: 16) {
                            Text(product.label)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary.opacity(0.8))
                            
                            Spacer()
                            
                            Button(action: {
                                guard product.quantity > 0 else {
                                    return
                                }
                                product.quantity -= 1
                            }, label: {
                                Image(systemName: "minus.square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 24)
                                    .foregroundStyle(.secondary.opacity(0.8))
                            })
                            .buttonRepeatBehavior(.enabled)
                            
                            Text(String(product.quantity))
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary.opacity(0.8))
                                .frame(width: 24)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)

                            
                            Button(action: {
                                product.quantity += 1
                            }, label: {
                                Image(systemName: "plus.square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 24)
                                    .foregroundStyle(.link.opacity(0.8))
                            })
                            .buttonRepeatBehavior(.enabled)

                        }
                    }
                }
                
                Section("Coupon") {
                    VStack {
                        HStack(spacing: 24) {
                            TextField("", text: $couponEntry)
                                .autocorrectionDisabled()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 4).fill(.background).stroke(.secondary, style: .init()))

                            Button(action: {
                                guard !couponEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                                    return
                                }
                                if let coupon = Coupon.couponAvailable.first(where: {$0.code == self.couponEntry.uppercased()}) {
                                    self.paymentManager.cart.coupon = coupon
                                    self.couponEntry = ""
                                } else {
                                    self.couponEntryError = "Invalid Coupon code."
                                }
                            }, label: {
                                Text("USE")
                                    .fontWeight(.semibold)
                            })
                            .buttonStyle(.glassProminent)
                            .buttonBorderShape(.roundedRectangle)
                        }
                        
                        Text("One Coupon Per Order")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)


                        if let couponEntryError {
                            Text(couponEntryError)
                                .foregroundStyle(.red)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        
                        if let coupon = self.paymentManager.cart.coupon {
                            HStack(spacing: 24) {
                                Text("Coupon Applied")
                                    .fontWeight(.semibold)
                                Text(coupon.code)
                                    .foregroundStyle(.secondary)

                            }
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                    }
                    .listRowInsets(.all, 24)
                    
                    
                }
                
                Section("Shipping") {
                    
                    ForEach(ShippingMethod.shippingAvailable) { shippingMethod in
                        let isCurrentSelected = shippingMethod == self.paymentManager.cart.shipping
                        Button(action: {
                            self.paymentManager.cart.shipping = shippingMethod
                        }, label: {
                            HStack(spacing: 24) {
                                VStack(alignment: .leading, spacing: 8, content: {
                                    HStack {
                                        Text(shippingMethod.label)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary.opacity(0.8))
                                        
                                        Text("\(String(format: "%.2f", shippingMethod.amount.doubleValue)) \(MerchantInformation.currencyCode)")
                                            .foregroundStyle(.secondary)
                                            .font(.caption)

                                    }

                                    Text(shippingMethod.detail)
                                        .foregroundStyle(.secondary)
                                        .font(.caption)

                                })
                                
                                Spacer()
                                
                                Image(systemName: isCurrentSelected ? "record.circle" : "circle")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 16)
                                    .foregroundStyle(.link)
                                    .fontWeight(.bold)

                            }

                        })
                    }
                }

                Section {
                    PayWithApplePayButton(.checkout, action: {
                        self.paymentManager.processingPayment = true
                    }, fallback: {
                        Text("Apple Pay Unavailable")
                    })
                    .frame(height: 48)
                    // will go infinite large otherwise when not used within a list cell
                    // .fixedSize(horizontal: true, vertical: true)
                    .payWithApplePayButtonStyle(.black)
                    .clipShape(Capsule())
                    .listRowInsets(.horizontal, 0)
                    .listRowBackground(Color.clear)
                }
                
                // NOT using the following because request created this way will never be updated based on the cart because of the following error.
                // - Accessing Environment's value outside of being installed on a View. This will always read the default value and will not update.
                //
                // When will the following work, ie: Apple pay sheet showing up with the request that reflects the latest cart?
                // When we have some intermediate views.
                // For example, having a button, upon click, create the request, and upon request creation, show PayWithApplePayButton with the request.
                //
                // PayWithApplePayButton(.checkout, request: self.paymentManager.createPaymentRequest(), onPaymentAuthorizationChange: { authorizationPhase in
                //     if case .didAuthorize(let payment, let resultHandler) = authorizationPhase {
                //         resultHandler(.init(status: .success, errors: []))
                //     }
                // }, fallback: {
                //     Text("Apple Pay Unavailable")
                // })
                // .fixedSize() // will go infinite large otherwise
                // .payWithApplePayButtonStyle(.black)
                // .onApplePayCouponCodeChange(perform: { couponCode in
                //     print("coupon code changed")
                //     return .init(errors: [], paymentSummaryItems: [], shippingMethods: [])
                // })
                // .onApplePayShippingMethodChange(perform: { ShippingMethod in
                //     print("shipping method changed")
                //     return .init(paymentSummaryItems: [])
                // })
            
            }
            .buttonStyle(.plain)
            .contentMargins(.top, 8)
            .navigationTitle("Apple Pay Demo")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $paymentManager.processingPayment, content: {
                let paymentRequest = self.paymentManager.createPaymentRequest()
                if let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
                    PaymentAuthorizationView(controller: controller)
                        .presentationDetents([.height(10)]) // set to a fairly small number because the actual payment view is another sheet on top of the PKPaymentAuthorizationViewController. If we don't set this, we will see another sheet behind the sheet
                        .environment(self.paymentManager)
                }
            })
            .navigationDestination(isPresented: $paymentManager.showProcessingSuccess, destination: {
                PaymentSuccessView()
            })
            .alert("Checkout Cancelled", isPresented: $paymentManager.showProcessingCancelled, actions: {})
            .overlay(alignment: .center, content: {
                if !self.paymentManager.canMakePayment {
                    ContentUnavailableView("Apple Pay Unavailable", systemImage: "creditcard.trianglebadge.exclamationmark")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Rectangle().fill(.background).fill(.secondary.opacity(0.5)))
                        .ignoresSafeArea(.container)
                }
                
            })
        

        }
    }
}
