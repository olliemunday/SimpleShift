//
//  FixedDatePicker.swift
//  SwiftShift
//
//  Created by Ollie on 29/03/2022.
//

import SwiftUI

struct FixedDatePicker: View {
    
    @Binding var selection: Date
    
    var body: some View {
        DatePicker("", selection: $selection, displayedComponents: [.date])
            .datePickerStyle(.wheel)
            .clipped()
            .labelsHidden()
            .id(selection)
    }
}
