//
//  SettingsLabel.swift
//  SwiftShift
//
//  Created by Ollie on 11/11/2022.
//

import SwiftUI

struct ImageLabel: View {

    let title: String
    let systemName: String
    let color: Color
    var symbolColor: Color = .white

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(color)
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(symbolColor)
                    .padding(4)
                
            }
            .frame(width: 28, height: 28, alignment: .center)
            Text(title)
                .foregroundColor(.primary)
        }
    }
}

struct ImageLabel_Previews: PreviewProvider {
    static var previews: some View {
        ImageLabel(title: "iCloud Sync", systemName: "cloud.fill", color: .blue)
    }
}
