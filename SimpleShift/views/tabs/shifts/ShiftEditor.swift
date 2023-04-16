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

    @State private var showGradient: Int = 0
    @State private var showCustomText: Int = 0
    @State private var customText: String = ""

    private enum NavigationType: String, Hashable {
        case gradientPreset = "Gradient"
    }

    @State private var navigationStack: [NavigationType] = []
    var body: some View {
        NavigationStack(path: $navigationStack) {
                VStack(spacing: 0) {
                    ShiftView(shift: shiftManager.editingShift)
                        .frame(width: 86, height: 144)
                        .scaleEffect(1.1)
                    List {
                        Section("shiftsettings", content: { textSettings })
                        Section("colorsettings", content: { colorSettings })
                        if !shiftManager.isNewShift { Section { delete } }
                    }

                    .environment(\.defaultMinListRowHeight, 50)
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        showGradient = shiftManager.editingShift.gradient_1 == shiftManager.editingShift.gradient_2 ? 0 : 1
                        showCustomText = shiftManager.editingShift.isCustom
                    }
                    .navigationDestination(for: NavigationType.self, destination: { value in
                        switch value {
                        case .gradientPreset: gradientPresets
                        }
                    })
                    .animation(.default, value: showCustomText)
                    .animation(.default, value: showGradient)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("cancel") { dismiss() }
                                .foregroundColor(.red)

                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(shiftManager.isNewShift ? "add" : "save") {
                                shiftManager.setShift(template: shiftManager.editingShift)
                                dismiss()
                            }
                            .bold()
                            .disabled(shiftManager.editingShift.shift.isEmpty)
                        }
                    }
                }

                    .background(Color("GenericBackground"))
        }
    }

    @ViewBuilder private var textSettings: some View {
        Picker("Show custom text", selection: $showCustomText) {
            Text("time").tag(0)
            Text("custom").tag(1)
//            Text("emoji").tag(2)
        }
            .pickerStyle(.segmented)
            .onChange(of: showCustomText) { val in
                shiftManager.editingShift.isCustom = showCustomText
                if shiftManager.editingShift.shift == shiftManager.getEditingShiftTimeString() {
                    shiftManager.editingShift.shift = ""
                }
            }

        if showCustomText == 0 {
            DatePicker(String(localized: "starttime"), selection: $shiftManager.editingShift.startTime, displayedComponents: [.hourAndMinute])
                .environment(\.locale, Locale(identifier: "en_GB"))
                .environment(\.timeZone, .gmt)
                .onChange(of: shiftManager.editingShift.startTime) { _ in
                    shiftManager.editingShift.isCustom = 0
                    if let string = shiftManager.getEditingShiftTimeString() {
                        shiftManager.editingShift.shift = string
                    }
                }
                .onAppear {
                    if let string = shiftManager.getEditingShiftTimeString() {
                        shiftManager.editingShift.shift = string
                    }
                }

            DatePicker(String(localized: "endtime"), selection: $shiftManager.editingShift.endTime, displayedComponents: [.hourAndMinute])
                .environment(\.locale, Locale(identifier: "en_GB"))
                .environment(\.timeZone, .gmt)
                .onChange(of: shiftManager.editingShift.endTime) { _ in
                    shiftManager.editingShift.isCustom = 0
                    if let string = shiftManager.getEditingShiftTimeString() {
                        shiftManager.editingShift.shift = string
                    }
                }
        }

        if showCustomText == 1 {
            TextField("custom", text: $customText)
                .onReceive(customText.publisher.collect()) { _ in
                    if customText.count >= 10 {
                        customText = String(customText.prefix(10))
                    } else {
                        customText = customText.filter { $0.isLetter || $0.isNumber || $0.isPunctuation || $0 == " " }
                    }
                }
                .onAppear(perform: { customText = shiftManager.editingShift.shift })
                .onChange(of: customText, perform: { shiftManager.editingShift.shift = $0 })
        }

//        if showCustomText == 2 {
//            Rectangle()
//        }
    }

    @ViewBuilder private var colorSettings: some View {
        Picker("Color selection", selection: $showGradient) {
            Text("solid").tag(0)
            Text("gradient").tag(1)
        }
            .pickerStyle(.segmented)
            .onChange(of: showGradient) { showGrad in
                if showGrad == 0 { shiftManager.editingShift.gradient_2 = shiftManager.editingShift.gradient_1 }
            }

        if showGradient == 0 {
            ColorPicker("color", selection: $shiftManager.editingShift.gradient_1)
                .onChange(of: shiftManager.editingShift.gradient_1) { col in
                    if showGradient == 0 {
                        shiftManager.editingShift.gradient_2 = shiftManager.editingShift.gradient_1
                    }
                }
        } else {
            ColorPicker("topcolor", selection: $shiftManager.editingShift.gradient_1)
            ColorPicker("bottomcolor", selection: $shiftManager.editingShift.gradient_2)
            NavigationLink("presets", value: NavigationType.gradientPreset)
        }
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
                            (shiftManager.editingShift.gradient_1, shiftManager.editingShift.gradient_2) = (preset.color1, preset.color2); navigationStack.removeAll()
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
                shiftManager.deleteShift(shift: shiftManager.editingShift)
                dismiss()
            } label: {
                Text("Delete")
            }

        })
    }

}
