//
//  SensePreferences.swift
//  SwiftShift
//
//  Created by Ollie on 02/04/2022.
//

import Foundation
import SwiftUI

struct SensePreferenceData: Equatable {
    let index: Int
    let bounds: CGRect
    
    // Optional data
    var weekId: UUID? = nil
}

struct SensePreferenceKey: PreferenceKey {
    static var defaultValue: [SensePreferenceData] = []
    
    static func reduce(value: inout [SensePreferenceData], nextValue: () -> [SensePreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}
