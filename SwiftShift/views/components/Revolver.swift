//
//  Revolver.swift
//  SwiftShift
//
//  Created by Ollie on 30/10/2022.
//

import SwiftUI

struct Revolver: View {
//    @State var displayArray = [View]()
    @State var displayIndex = 0

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)

    }

    private var view1: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.red)
            .opacity(0.8)
    }

    private var view2: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.blue)
            .opacity(0.8)
    }

    private var view3: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.blue)
            .opacity(0.8)
    }

}

struct Revolver_Previews: PreviewProvider {
    static var previews: some View {
        Revolver()
    }
}
