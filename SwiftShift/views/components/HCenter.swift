//
//  HCenter.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct HCenter<T: View>: View {
    let content: T

    init(@ViewBuilder content: () -> T) {
        self.content = content()
    }

    var body: some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

