//
//  Date+Extensions.swift
//  SimpleShift
//
//  Created by Ollie on 23/07/2023.
//

import Foundation

extension Date {

    /// Function to round a date to the nearest hour
    func roundToNearestHour() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        return calendar.date(from: components)!
    }
    
}
