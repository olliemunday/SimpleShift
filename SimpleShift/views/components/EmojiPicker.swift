//
//  EmojiPicker.swift
//  SimpleShift
//
//  Created by Ollie on 16/04/2023.
//

import SwiftUI
import UIKit
import ElegantEmojiPicker


struct EmojiPicker: UIViewControllerRepresentable {

    @Binding var string: String
    public var showSearch: Bool = true
    public var showRandom: Bool = false
    public var showReset: Bool = false
    public var showClose: Bool = false
    public var showToolbar: Bool = true
    public var supportsPreview: Bool = true
    public var showBackground: Bool = true

    class Coordinator: NSObject, ElegantEmojiPickerDelegate {
        private var parent: EmojiPicker

        func emojiPicker(_ picker: ElegantEmojiPicker, didSelectEmoji emoji: Emoji?) {
            guard let emoji = emoji else { return }
            parent.string = emoji.emoji
        }

        init(_ parent: EmojiPicker) {
            self.parent = parent
        }
    }

    func makeUIViewController(context: Context) -> ElegantEmojiPicker {
        let config = ElegantConfiguration(showSearch: showSearch,
                                          showRandom: showRandom,
                                          showReset: showReset,
                                          showClose: showClose,
                                          showToolbar: showToolbar,
                                          supportsPreview: supportsPreview)
        let picker = ElegantEmojiPicker(delegate: context.coordinator,
                                        configuration: config)

        if !showBackground, let visualEffectView = picker.view.subviews.first(where: { $0 is UIVisualEffectView }) {
            visualEffectView.removeFromSuperview()
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: ElegantEmojiPicker, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// Replace background with a UIBlurEffect for use with the sheet

struct EmojiBlurBackground: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPicker(string: .constant(""))
            .frame(height: 400)
    }
}
