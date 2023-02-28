//
//  ImageButton.swift
//  SwiftShift
//
//  Created by Ollie on 03/04/2022.
//

import SwiftUI

struct ImageButton: View {
    let arrow: String
    let size: CGFloat
    var color: Color = .blue
    var imageColor: Color = .white

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size / 3.5)
                .foregroundColor(color)
            Image(systemName: arrow)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size/1.5, height: size/1.5, alignment: .center)
                .foregroundColor(imageColor)
        }
            .frame(width: size, height: size)
            .drawingGroup()
    }
}

struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ImageButton(arrow: "arrow.left.circle.fill", size: 200)
                .shadow(radius: 5.0)
        }
    }
}
