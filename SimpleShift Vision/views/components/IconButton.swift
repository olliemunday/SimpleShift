//
//  IconButton.swift
//  SimpleShift visionOS
//
//  Created by Ollie on 07/08/2023.
//

import SwiftUI

struct IconButton: View {

    let text: String
    var systemName: String? = nil
    let action: () -> ()

    var body: some View {
        Button { action() }
        label: {
            HStack{
                Text(text)
                if let systemName = systemName {
                    Image(systemName: systemName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26)
                }
            }
        }

    }
}

#Preview {
    IconButton(text: "Add Shift", systemName: "plus") {

    }
}
