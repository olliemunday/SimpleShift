//
//  TickMarker.swift
//  SwiftShift
//
//  Created by Ollie on 02/04/2022.
//

import SwiftUI

struct CustomMarker: View {
    let size: CGFloat
    let primary: Color
    let secondary: Color = .white
    let icon: String
    
    @ViewBuilder var body: some View {
        ZStack {
            Circle()
                .foregroundColor(primary)
            Circle()
                .strokeBorder(secondary, lineWidth: size/14)
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(secondary)
                .frame(width: size/2, height: size/2, alignment: .center)
        }
        .frame(width: size, height: size, alignment: .center)
        .drawingGroup()
    }
}

struct TickMarker: View {
    let size: CGFloat
    
    var body: some View {
        CustomMarker(size: size, primary: .blue, icon: "checkmark")
    }
}

struct MinusMarker: View {
    let size: CGFloat
    
    var body: some View {
        CustomMarker(size: size, primary: .red, icon: "minus")
    }
}

struct TickMarker_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TickMarker(size: 200)
                .shadow(radius: 8)
                .padding()
            CustomMarker(size: 200, primary: .green, icon: "star.fill")
                .padding()
                .shadow(radius: 8)
        }
    }
}
