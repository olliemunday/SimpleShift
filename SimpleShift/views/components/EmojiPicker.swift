//
//  EmojiPicker.swift
//  SimpleShift
//
//  Created by Ollie on 16/04/2023.
//

import SwiftUI

struct EmojiPicker: View {

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(emojiList.values.sorted(), id: \.self) { emoji in
                    Rectangle()
                        .cornerRadius(20)
                        .frame(width: 64, height: 64)
                        .overlay {
                            Text(emoji)
                                .font(.largeTitle)
                                .dynamicTypeSize(.large ... .large)
                        }
                }
            }
        }
    }
}

struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPicker()
    }
}
