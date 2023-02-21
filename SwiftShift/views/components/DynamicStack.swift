//
//  DynamicStack.swift
//  SwiftShift
//
//  Created by Ollie on 11/11/2022.
//

import SwiftUI

struct DynamicStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat = 10.0, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        

        switch sizeClass {
        case .regular:
            hStack
        case .compact, .none:
            vStack
        @unknown default:
            vStack
        }
    }

    private var vStack: some View {
        VStack(alignment: .center, spacing: spacing, content: {content})
    }

    private var hStack: some View {
        HStack(alignment: .top, spacing: spacing, content: {content})
    }
}
