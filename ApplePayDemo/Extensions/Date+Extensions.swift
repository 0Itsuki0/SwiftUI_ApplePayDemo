//
//  Date.swift
//  ApplePayDemo
//
//  Created by Itsuki on 2025/11/30.
//

import Foundation

extension Date {
    var dateComponents: DateComponents {
        return Calendar.current.dateComponents([.calendar, .year, .month, .day], from: self)
    }
}
