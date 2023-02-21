//
//  MultiSelector.swift
//  SwiftShift
//
//  Created by Ollie on 02/09/2022.
//

import SwiftUI

struct MultiSelector: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selected: Int
    
    var options: [String]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                let sizew = (geo.size.width / CGFloat(options.count))
                let sizeh = geo.size.height
                let selW = (sizew/2) - (sizew * CGFloat(options.count) / 2)
                RoundedRectangle(cornerRadius: 8.0)
                    .foregroundColor(Color("MultiSelector_bg"))
                ZStack {
                    RoundedRectangle( cornerRadius: 8.0)
                        .opacity(0.5)
                        .foregroundColor(Color("MultiSelector_fg"))
                        .frame(width: max(sizew - 6, 1), height: max(sizeh - 6, 1))
                        
                        .shadow(radius: 2)
                    Rectangle()
                        .frame(width: max(sizew, 1), height: max(sizeh, 1))
                        .opacity(0)
                }
                .offset(x: selW, y:0)
                .offset(x: -sizew + (sizew * CGFloat(selected+1)), y: 0)

                HStack {
                    ForEach(0...options.count-1, id: \.self) { i in
                            Button {
                                withAnimation(.interactiveSpring(response: 0.33, dampingFraction: 0.86, blendDuration: 0.25)) {
                                    selected = i
                                }
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .opacity(0.0)
                                    Text(options[i])
                                        .truncationMode(.tail)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .scaleEffect(selected == i ? 1.0 : 0.94)
                                }
                            }
                    }
                }
            }
        }
    }
    
    
    
    
}
