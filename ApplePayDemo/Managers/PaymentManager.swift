//
//  PaymentManager.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import PassKit
import SwiftUI

@Observable
class PaymentManager: NSObject {
    static let tax: NSDecimalNumber = 0.1

    var processingPayment: Bool = false {
        didSet {
            guard !processingPayment else {
                return
            }
            switch self.processingResult {
            case .success:
                showProcessingSuccess = true
            default:
                showProcessingCancelled = true
            }
        }
    }
    
    var showProcessingSuccess: Bool = false {
        didSet {
            if !showProcessingSuccess {
                // set to the initial value
                self.cart = Cart()
            }
        }
    }
    
    var showProcessingCancelled: Bool = false

    private var processingResult: PKPaymentAuthorizationStatus? = nil
    
    var cart: Cart = Cart()

    
    // Apple Pay Availability
    // On devices that support making payments but don’t have any payment cards configured, the canMakePayments(usingNetworks:) method returns false regardless of network.
    var canMakePayment: Bool {
        // we are using canMakePayments() instead of canMakePayments(usingNetworks:)
        // because If there are no configured payment cards, canMakePayments(usingNetworks:) always returns false
        // whereas canMakePayments() returns true if the device supports making payments.
        // User can then add other payment method within the Apple Pay Sheet.
        return PKPaymentAuthorizationController.canMakePayments()
    }
   
    
    // Create PKPaymentRequest: https://developer.apple.com/documentation/passkit/pkpaymentrequest
    // A payment request object contains information that describes the purchase, including information about the merchant, available payment networks, the payment summary, billing and shipping details, coupon codes, custom data, error messages, and more.
    //
    //  Your app creates a payment request as soon as a person taps the Apple Pay button to make a purchase. Tapping the Apple Pay button in your app initiates the payment request process.
    // If your customers need to enter a discount code, choose a shipping method, or any other task, your app needs to ask for that information before they tap the Apple Pay button.
    func createPaymentRequest() -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        
        // Selecting the payment networks
        // the payment methods that the user can select to fund the payment
        paymentRequest.supportedNetworks = MerchantInformation.supportedNetworks

        // Setting merchant information
        paymentRequest.merchantIdentifier = MerchantInformation.merchantId
        paymentRequest.merchantCategoryCode = nil

        // The threeDSecure and emv values of PKMerchantCapability specify the supported cryptographic payment protocols.
        // At least one of these two values is required.
        // To filter the types of cards to make available for the transaction, pass the credit and debit values. If neither is passed, all card types will be available.
        paymentRequest.merchantCapabilities = .threeDSecure
        
        // Setting currency and region information
        paymentRequest.currencyCode = MerchantInformation.currencyCode
        paymentRequest.countryCode = MerchantInformation.merchantCountryCode
        paymentRequest.supportedCountries = nil

        // Setting the payment summary items
        paymentRequest.paymentSummaryItems = self.createSummaryItems()
        
        // Requesting recurring, automatic, and deferred payments
        // An optional request to set up a recurring payment, typically a subscription.
        // You can’t use this property with multiTokenContexts or automaticReloadPaymentRequest properties.
        // Simultaneous use of these properties results in a runtime error and cancels the payment request.
        paymentRequest.recurringPaymentRequest = nil
        
        // An optional request to set up an automatic reload payment, such as a store card top-up.
        // You can’t use this property with multiTokenContexts or recurringPaymentRequest or deferredPaymentRequest properties.
        paymentRequest.automaticReloadPaymentRequest = nil
        
        // A request to set up a deferred payment, such as a hotel booking or a pre-order.
        paymentRequest.deferredPaymentRequest = nil
        
        // Requesting multitoken or multimerchant payments
        // Use multitoken contexts to indicate payments for multiple merchants
        // You can’t use this property with recurringPaymentRequest or automaticReloadPaymentRequest properties
        paymentRequest.multiTokenContexts = []
        
        // Requesting billing and shipping contact fields
        paymentRequest.requiredBillingContactFields = [.name, .emailAddress, .phoneNumber]
        paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
        // If you have an up-to-date billing address on file, you can set it here.
        // This billing address appears in the payment sheet. The user can either use the address you specify or select a different address.
        // Note that a PKContact object that represents a billing contact contains information for only the postalAddress property. All other properties in the object are set to nil.
        paymentRequest.billingContact = nil
        // If you have an up-to-date shipping address on file, you can set this property to that address. This shipping address appears in the payment sheet. When the framework presents the PKPaymentAuthorizationViewController, the user can either keep the address you specified or enter a different address.
        // Note that a PKContact object that represents a shipping contact contains information for only the postalAddress, emailAddress, and phoneNumber properties. The framework sets all other properties in the object to nil.
        paymentRequest.shippingContact = nil
        
        // Setting the shipping methods and types
        // For Displaying a Read-Only Pickup Address when using PKShippingType.storePickup: https://developer.apple.com/documentation/passkit/displaying-a-read-only-pickup-address
        paymentRequest.shippingType = .delivery
        paymentRequest.shippingContactEditingMode = .available
        // make sure that the current selected one (if an in app selection is provided) comes first because that is the one that will be the one automatically selected by the Apple Pay sheet
        paymentRequest.shippingMethods = ShippingMethod.shippingAvailable.map(\.paymentMethod).sorted(currentSelected: cart.shipping.paymentMethod)

        // Working with coupon codes
        paymentRequest.supportsCouponCode = true
        // Set the value to nil or the empty string to indicate that there’s no initial coupon.
        // The system doesn’t send a change event for an initial coupon code. You must apply the code to the initial payment summary items.
        // ie: add a discount PKPaymentSummaryItem above
        paymentRequest.couponCode = self.cart.coupon?.code
        
        // Adding custom data
        // Use this property for additional data as may be appropriate for your app—for example, a shopping cart identifier or an order number.
        // A hash of this data is included in the signed payment data (the paymentData property of PKPaymentToken).
        // You are responsible for sending the full application data to your server, if needed.
        paymentRequest.applicationData = nil
        
        return paymentRequest
    }
    
        
    // Required for the total amount:
    // - Set the grand total amount to the sum of all the other items in the array. This amount must be greater than or equal to zero.
    // - Set the grand total label to the name of your company. This label represents the person or company receiving payment.
    // summaryItems: product, coupon, shipping, tax
    private func createTotalPaymentItem(summaryItems: [PKPaymentSummaryItem]) -> PKPaymentSummaryItem {
        let totalAmount = summaryItems.map(\.amount).total
        return PKPaymentSummaryItem(label: "Itsuki's World", amount: totalAmount.twoDecimal, type: .final)
    }
    
    // summaryItems: product, coupon, shipping
    private func createTaxPaymentItem(summaryItems: [PKPaymentSummaryItem]) -> PKPaymentSummaryItem {
        let taxAmount = summaryItems.map(\.amount).total.multiplying(by: PaymentManager.tax)
        return PKPaymentSummaryItem(label: "TAX", amount: taxAmount.twoDecimal, type: .final)
    }
    
    
    // PKPaymentSummaryItem: for an immediate payment.
    // KDeferredPaymentSummaryItem: for a payment that occurs in the future, such as a pre-order.
    // PKRecurringPaymentSummaryItem: for a payment that occurs more than once, such as a subscription.
    //
    // Apple Pay uses the last item in the paymentSummaryItems array as the grand total for the purchase.
    // As a result, there are additional requirements placed on both its amount and its label.
    // - Set the grand total amount to the sum of all the other items in the array. This amount must be greater than or equal to zero.
    // - Set the grand total label to the name of your company. This label represents the person or company receiving payment.
    private func createSummaryItems() -> [PKPaymentSummaryItem] {
        let products = cart.products
        let coupon = cart.coupon
        let shippingMethod = cart.shipping
        
        var summaryItems = products.map(\.paymentSummaryItem)
        if let coupon {
            let discount = coupon.createPaymentSummaryItem(products: products)
            summaryItems.append(discount)
        }
        
        // For shipping cost, use the PKShippingMethod
        // we need to add/update this manually by ourselves.
        summaryItems.append(shippingMethod.paymentMethod)
        let tax = self.createTaxPaymentItem(summaryItems: summaryItems)
        summaryItems.append(tax)
        let total = createTotalPaymentItem(summaryItems: summaryItems)
        summaryItems.append(total)
        
        return summaryItems
    }
    
    // Verify the authorized payment by decrypting the data with the private key.
    //
    // Send the the payment token to server or payment provider for Verify the signature and decrypt the payment data.
    // https://developer.apple.com/documentation/PassKit/payment-token-format-reference
    private func verifyPayment(_ payment: PKPayment) async throws {
        print(#function)
        if payment.shippingContact?.name?.givenName?.uppercased() != "ITSUKI" {
            let error = PKPaymentRequest.paymentContactInvalidError(withContactField: .name, localizedDescription: "I don't send my hello, like, or love to anyone other than myself!")
            throw error
        }
        
    }
}

extension PaymentManager: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        print(#function)
        // PKPaymentAuthorizationViewController doesn't automatically dismiss after finish
        controller.dismiss(animated: true)
        self.processingPayment = false
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment) async -> PKPaymentAuthorizationResult {
        print("didAuthorizePayment")
        do {
            try await self.verifyPayment(payment)
            self.processingResult = .success
            return PKPaymentAuthorizationResult(status: .success, errors: [])

        } catch(let error) {
            print(error)
            self.processingResult = .failure
            return PKPaymentAuthorizationResult(status: .failure, errors: [error])
        }
    }
    
    
    // update item summary (total amount) based on the coupon applied
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didChangeCouponCode couponCode: String) async -> PKPaymentRequestCouponCodeUpdate {
        print("didChangeCouponCode")
        let shippingMethod = ShippingMethod.shippingAvailable.map(\.paymentMethod)
        
        if couponCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return PKPaymentRequestCouponCodeUpdate(errors: [], paymentSummaryItems: self.createSummaryItems(), shippingMethods: shippingMethod)
        }
        
        guard self.cart.coupon == nil else {
            let error = PKPaymentRequest.paymentCouponCodeInvalidError(localizedDescription: "A Coupon is already applied")
            return PKPaymentRequestCouponCodeUpdate(errors: [error], paymentSummaryItems: self.createSummaryItems(), shippingMethods: shippingMethod)
        }

        guard let coupon = Coupon.couponAvailable.first(where: {$0.code == couponCode.uppercased()}) else {
            let error = PKPaymentRequest.paymentCouponCodeInvalidError(localizedDescription: "Invalid Coupon Code.")
            return PKPaymentRequestCouponCodeUpdate(errors: [error], paymentSummaryItems: self.createSummaryItems(), shippingMethods: shippingMethod)
        }
        
        self.cart.coupon = coupon
        return PKPaymentRequestCouponCodeUpdate(errors: [], paymentSummaryItems: self.createSummaryItems(), shippingMethods: shippingMethod)
    }
    
    // Update item summary (total amount) based on the shipping cost
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod) async -> PKPaymentRequestShippingMethodUpdate {
        print("didSelect shippingMethod")
        guard let shippingMethod = ShippingMethod.shippingAvailable.first(where: {$0.id == shippingMethod.identifier}) else {
            return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: self.createSummaryItems())
        }
        
        self.cart.shipping = shippingMethod
        return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: self.createSummaryItems())
        
    }
}
