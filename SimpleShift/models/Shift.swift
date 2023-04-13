//
//  ShiftDescriptor.swift
//  SwiftShift
//
//  Created by Ollie on 03/04/2022.
//

import Foundation
import SwiftUI
import CloudKit

struct Shift: Identifiable, Equatable, Hashable {

    var id: UUID = UUID()
    var shift: String = ""

    var isCustom: Int = 0
    var startTime = Date(timeIntervalSinceReferenceDate: .zero)
    var endTime = Date(timeIntervalSinceReferenceDate: .zero)

    var gradient_1: Color = Color.hex("65788A")
    var gradient_2: Color = Color.hex("65788A")

    var ckrecord: CKRecord?

    var hide: Bool = false
    
    var gradientArray: [Color] { [gradient_1, gradient_2] }
}
