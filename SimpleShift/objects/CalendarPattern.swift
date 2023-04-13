//
//  CalendarPattern.swift
//  SimpleShift
//
//  Created by Ollie on 12/04/2023.
//

import Foundation

// Hold the data to share between the Calendar and Patterns tab.

class CalendarPattern: ObservableObject {
    // Variable to hold pattern that is being applied.
    public var applyingPattern: Pattern?
    @Published var isApplyingPattern: Bool = false

    public func deselectPattern() {
        applyingPattern = nil
        isApplyingPattern = false
    }
}
