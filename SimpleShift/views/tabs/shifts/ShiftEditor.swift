//
//  ShiftEditor.swift
//  SwiftShift
//
//  Created by Ollie on 26/10/2022.
//

import SwiftUI

struct ShiftEditor: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var shiftManager: ShiftManager

    let isNewShift: Bool
    @State var shift: Shift
    @State private var showGradient: Int = 0
    @State private var showCustomText: Int = 0
    @State private var showEmojiPicker: Bool = false

    private enum NavigationType: String, Hashable {
        case gradientPreset = "Gradient"
    }

    @State private var navigationStack: [NavigationType] = []
    var body: some View {
        NavigationStack(path: $navigationStack) {
                VStack(spacing: 0) {
                    ShiftView(shift: shift)
                        .frame(width: 100, height: 140)
                        .disabled(true)
                    List {
                        textSettings
                        colorSettings
                        if !isNewShift { Section { delete } }
                    }
                    .navigationDestination(for: NavigationType.self, destination: { value in
                        switch value {
                        case .gradientPreset: gradientPresets
                        }
                    })
                    .scrollContentBackground(.hidden)
                    .animation(.default, value: shift.isCustom)
                    .animation(.default, value: showGradient)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("cancel") { dismiss() }
                                .foregroundColor(.red)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(isNewShift ? "add" : "save") {
                                shiftManager.setShift(template: shift)
                                dismiss()
                            }
                            .bold()
                            .disabled(shift.shift.isEmpty)
                        }
                    }
                }
                .background(Color("GenericBackground"))
        }
    }

    private var textSettings: some View {
        Section("shiftsettings", content: {
            Picker("Show custom text", selection: $shift.isCustom) {
                Text("time").tag(0)
                Text("text").tag(1)
                Text("emoji").tag(2)
            }
                .pickerStyle(.segmented)
                .onChange(of: shift.isCustom) {
                    if $0 == 0 {
                        if let string = shiftManager.getShiftTimeString(shift) {
                            shift.shift = string
                        }
                    }
                    if $0 == 2 { shift.shift = "" }
                }

            if shift.isCustom == 0 {
                DatePicker(String(localized: "starttime"), selection: $shift.startTime, displayedComponents: [.hourAndMinute])
                    .environment(\.locale, Locale(identifier: "en_GB"))
                    .environment(\.timeZone, .gmt)
                    .onChange(of: shift.startTime) { _ in
                        if let string = shiftManager.getShiftTimeString(shift) {
                            shift.shift = string
                        }
                    }

                DatePicker(String(localized: "endtime"), selection: $shift.endTime, displayedComponents: [.hourAndMinute])
                    .environment(\.locale, Locale(identifier: "en_GB"))
                    .environment(\.timeZone, .gmt)
                    .onChange(of: shift.endTime) { _ in
                        if let string = shiftManager.getShiftTimeString(shift) {
                            shift.shift = string
                        }
                    }
            }

            if shift.isCustom == 1 {
                TextField("text", text: $shift.shift)
                    .onReceive(shift.shift.publisher.collect()) {
                        let text = String($0)
                        if let time = shiftManager.getShiftTimeString(shift) {
                            if text == time { shift.shift = ""; return }
                        }
                        if text.count >= 10 {
                            shift.shift = String(text.prefix(10))
                        } else {
                            shift.shift = text.filter { $0.isLetter || $0.isNumber || $0.isPunctuation || $0 == " " }
                        }
                    }
            }

            if shift.isCustom == 2 {
                Button("selectemoji") {
                    showEmojiPicker.toggle()
                }
                .foregroundColor(Color.primary)
                .sheet(isPresented: $showEmojiPicker) {
                    EmojiPicker(string: $shift.shift, showBackground: false)
                        .ignoresSafeArea()
                        .presentationDetents([.medium, .large])
                        .background(
                            EmojiBlurBackground(style: .systemUltraThinMaterial)
                                .ignoresSafeArea()
                        )

                }
            }
        })
    }

    private var colorSettings: some View {
        Section("colorsettings", content: {
            Picker("Color selection", selection: $showGradient) {
                Text("solid").tag(0)
                Text("gradient").tag(1)
            }
                .pickerStyle(.segmented)
                .onAppear {
                    showGradient = shift.gradient_1 == shift.gradient_2 ? 0 : 1
                }
                .onChange(of: showGradient) { showGrad in
                    if showGrad == 0 { shift.gradient_2 = shift.gradient_1 }
                }

            if showGradient == 0 {
                ColorPicker("color", selection: $shift.gradient_1)
                    .onChange(of: shift.gradient_1) { col in
                        if showGradient == 0 {
                            shift.gradient_2 = shift.gradient_1
                        }
                    }
            }
            if showGradient == 1 {
                ColorPicker("topcolor", selection: $shift.gradient_1)
                ColorPicker("bottomcolor", selection: $shift.gradient_2)
                NavigationLink("presets", value: NavigationType.gradientPreset)
            }
        })
    }

    ///================>
    /// Preset Gradient Picker
    ///================>

    private let presets: [GradientPreset] = [
        GradientPreset(id: "Aqua", color1: Color.hex("00b9ff"), color2: Color.hex("007aff")),
        GradientPreset(id: "Mint Green", color1: Color.hex("a8ff78"), color2: Color.hex("78ffd6")),
        GradientPreset(id: "Purplin", color1: Color.hex("a044ff"), color2: Color.hex("6a3093")),
        GradientPreset(id: "Sin City Red", color1: Color.hex("ED213A"), color2: Color.hex("93291E")),
        GradientPreset(id: "Citrus Peel", color1: Color.hex("FDC830"), color2: Color.hex("F37335")),
        GradientPreset(id: "Midnight City", color1: Color.hex("414345"), color2: Color.hex("232526")),
        GradientPreset(id: "Pacific Dream", color1: Color.hex("34e89e"), color2: Color.hex("0f3443")),
        GradientPreset(id: "Ibiza Sunset", color1: Color.hex("ff6a00"), color2: Color.hex("ee0979")),
        GradientPreset(id: "Very Blue", color1: Color.hex("0575E6"), color2: Color.hex("021B79")),
        GradientPreset(id: "Lush", color1: Color.hex("a8e063"), color2: Color.hex("56ab2f")),
        GradientPreset(id: "Reef", color1: Color.hex("00d2ff"), color2: Color.hex("3a7bd5")),
        GradientPreset(id: "Intuitive Purple", color1: Color.hex("DA22FF"), color2: Color.hex("9733EE")),
        GradientPreset(id: "Lemon", color1: Color.hex("FFE000"), color2: Color.hex("799F0C")),
        GradientPreset(id: "Martini", color1: Color.hex("FDFC47"), color2: Color.hex("24FE41")),
        GradientPreset(id: "Burning Orange", color1: Color.hex("FF416C"), color2: Color.hex("FF4B2B")),
        GradientPreset(id: "Skyline", color1: Color.hex("1488CC"), color2: Color.hex("2B32B2")),
        GradientPreset(id: "Ultra Voilet", color1: Color.hex("eaafc8"), color2: Color.hex("654ea3")),
        GradientPreset(id: "Mango", color1: Color.hex("ffe259"), color2: Color.hex("ffa751")),
        GradientPreset(id: "Tube Red", color1: Color.hex("e52d27"), color2: Color.hex("b31217")),
        GradientPreset(id: "Flare", color1: Color.hex("f5af19"), color2: Color.hex("f12711")),
        GradientPreset(id: "Blue Raspberry", color1: Color.hex("00B4DB"), color2: Color.hex("0083B0")),
        GradientPreset(id: "Celestial", color1: Color.hex("d93267"), color2: Color.hex("363f99")),
        GradientPreset(id: "Mauve", color1: Color.hex("734b6d"), color2: Color.hex("42275a")),
        GradientPreset(id: "Ash", color1: Color.hex("606c88"), color2: Color.hex("3f4c6b")),
        GradientPreset(id: "Aqualicious", color1: Color.hex("96DEDA"), color2: Color.hex("50C9C3")),
        GradientPreset(id: "Sha la la", color1: Color.hex("E29587"), color2: Color.hex("D66D75")),
        GradientPreset(id: "Venice", color1: Color.hex("A7BFE8"), color2: Color.hex("6190E8")),
        GradientPreset(id: "Mantle", color1: Color.hex("24C6DC"), color2: Color.hex("514A9D")),
        GradientPreset(id: "Cherry", color1: Color.hex("F45C43"), color2: Color.hex("EB3349")),
        GradientPreset(id: "80's Purple", color1: Color.hex("41295a"), color2: Color.hex("2F0743")),
        GradientPreset(id: "Sanguine", color1: Color.hex("FBB03B"), color2: Color.hex("D4145A")),
        GradientPreset(id: "Quepal", color1: Color.hex("38EF7D"), color2: Color.hex("11998E")),
        GradientPreset(id: "Toxic", color1: Color.hex("BFF098"), color2: Color.hex("6FD6FF")),
        GradientPreset(id: "Orbit", color1: Color.hex("92EFFD"), color2: Color.hex("4E65FF")),
        GradientPreset(id: "Mountain Rock", color1: Color.hex("868F96"), color2: Color.hex("596164")),
        GradientPreset(id: "Eternal Constance", color1: Color.hex("537895"), color2: Color.hex("09203F")),
    ]

    private var gradientPresets: some View {
        let gridSpacing: CGFloat = 4
        var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 3) }
        return GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                    ForEach(presets) { preset in
                        Button {
                            (shift.gradient_1, shift.gradient_2) = (preset.color1, preset.color2); navigationStack.removeAll()
                        } label: {
                            ZStack {
                                GradientRounded(cornerRadius: 16, colors: [preset.color1, preset.color2], direction: .vertical)
                                    .frame(height: geo.size.width / 3)

                                Text(preset.id)
                                    .padding()
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(preset.color2.textColor)
                                    .opacity(0.5)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .navigationTitle("Presets")
    }

    @State private var showDeleteAlert: Bool = false

    private var delete: some View {
        Button("delete", role: .destructive) {
            showDeleteAlert.toggle()
        }
        .alert("shiftdeletealert", isPresented: $showDeleteAlert, actions: {
            Button(role: .destructive) {
                showDeleteAlert.toggle()
                shiftManager.deleteShift(shift: shift)
                dismiss()
            } label: {
                Text("Delete")
            }

        })
    }

}
