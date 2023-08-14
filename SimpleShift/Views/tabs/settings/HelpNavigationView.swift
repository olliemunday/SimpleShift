//
//  HelpNavigationView.swift
//  SwiftShift
//
//  Created by Ollie on 03/03/2023.
//

import SwiftUI

struct HelpNavigationView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settingsManager: SettingsManager

    #if os(iOS)
    let optionCornerRadius = 20.0
    #else
    let optionCornerRadius = 40.0
    #endif

    var body: some View {
            ScrollView {
                Grid(alignment: .center, horizontalSpacing: 30, verticalSpacing: 30) {
                    GridRow(alignment: .center) {
                        NavigationLink(destination: {calendarHelp},
                                       label: { HelpViewOption(image: "calendar",
                                                                  text: String(localized: "calendar"),
                                                               colors: [Color.hex("FDFC47"), Color.hex("24FE41")],
                                                               tintColor: settingsManager.tintColor,
                                                               cornerRadius: optionCornerRadius)
                        })

                        NavigationLink(destination: {shiftHelp},
                                       label: { HelpViewOption(image: "square.stack.3d.down.forward",
                                                               text: String(localized: "shifts"),
                                                               colors: [Color.hex("f5af19"), Color.hex("f12711")],
                                                               tintColor: settingsManager.tintColor,
                                                               cornerRadius: optionCornerRadius )
                        })
                    }

                    GridRow {
                        NavigationLink(destination: {patternHelp},
                                       label: { HelpViewOption(image: "clock.arrow.2.circlepath",
                                                               text: String(localized: "patterns"),
                                                               colors: [Color.hex("96DEDA"), Color.hex("50C9C3")],
                                                               tintColor: settingsManager.tintColor, 
                                                               cornerRadius: optionCornerRadius)
                        })
                    }
                }
                .buttonStyle(.plain)
                .padding(30)
            }
        .navigationTitle("help")
    }

    @State var activateDragAnimation: Bool = false

    private var calendarHelp: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                HCenter {
                    Image(systemName: "calendar")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .padding()
                        .background(content: {Color.blue.cornerRadius(12)})
                        .padding()
                        .drawingGroup()
                        .shadow(radius: 2)
                }
                Text("calendarhelp1")
                calendarHelpNavigation
                calendarHelpEditing
                calendarHelpSharing
                Rectangle().frame(height: 20).hidden()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("calendar")
    }

    private var calendarHelpSharing: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("calendarhelp_sharingHeader")
                .font(.title)

            HCenter {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
                    .padding()
                    .background(content: {Color.blue.cornerRadius(12)})
            }

            Text("calendarhelp4")
        }
    }

    private var calendarHelpEditing: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("calendarhelp_editingHeader")
                .font(.title)

            HCenter {
                ZStack {
                    CalendarExampleView()
                    Image(systemName: "hand.tap.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48)
                        .foregroundColor(.primary)
                        .scaleEffect(1.4)
                        .shadow(radius: 2)
                        .padding(.top, 70)
                        .offset(x: activateDragAnimation ? 145 : -110)
                        .animation(.easeInOut(duration: 2.0).repeatForever(), value: activateDragAnimation)
                }
                .task { activateDragAnimation.toggle() }
            }

            Text("calendarhelp2")

            HCenter {
                Image(systemName: "square.stack.3d.down.forward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
                    .padding()
                    .background(content: {Color.blue.cornerRadius(12)})
            }

            Text("calendarhelp3")
        }
    }

    private var calendarHelpNavigation: some View {
        VStack(alignment: .leading,spacing: 10) {
            Text("calendarhelp_navigationHeader")
                .font(.title)

            calendarHelpNavigationBarDemo

            Text("calendarhelp_navigation1")
        }
    }

    @State private var date1 = String(localized: "demo_date1")
    @State private var date2 = String(localized: "demo_date2")
    @State private var barDate = String(localized: "demo_date1")
    @State private var barDateForward = true
    @State private var taskCreated: Bool = false
    

    private var calendarHelpNavigationBarDemo: some View {
        ZStack {
            Rectangle()
                .foregroundColor(settingsManager.tintColor.colorAdjusted(colorScheme))
                .opacity(0.15)
                .cornerRadius(12)
                .shadow(radius: 1)

            Text(barDate)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .dynamicTypeSize(.xLarge ... .xLarge)
                .transition(.asymmetric(insertion: .move(edge:  barDateForward ? .trailing : .leading).combined(with: .opacity),
                                        removal: .move(edge: barDateForward ? .leading : .trailing).combined(with: .opacity)))
                .frame(maxWidth: .infinity, alignment: .center)
                .id(barDate)
                .task {
                    if taskCreated == true { return }
                    Task {
                        taskCreated = true
                        while true {
                            try await Task.sleep(for: .seconds(6))
                            if barDate == date1 {
                                barDateForward = true
                                try await Task.sleep(for: .milliseconds(100))
                                barDate = date2
                                continue }
                            if barDate == date2 {
                                barDateForward = false
                                try await Task.sleep(for: .milliseconds(100))
                                barDate = date1
                                continue }
                        }
                    }
                }

            HStack {
                let tintColor = settingsManager.tintColor.colorAdjusted(colorScheme)
                let arrowColor = settingsManager.tintColor.textColor(colorScheme)
                ImageButton(arrow: "arrow.left.circle.fill", size: 36, color: tintColor, imageColor: arrowColor)
                    .padding(.leading, 5)
                Spacer()
                ImageButton(arrow: "arrow.right.circle.fill", size: 36, color: tintColor, imageColor: arrowColor)
                    .padding(.trailing, 5)
            }
        }
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: barDate)
        .padding(.horizontal, 20)
        .padding(.vertical)
        .frame(height: 76)
    }

    private var navigationBarHelp: some View {
        LazyVStack {
            HCenter {
                Image(systemName: "arrow.left.and.right.square")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .padding()
                    .background(content: {Color.blue.cornerRadius(12)})
                    .padding()
                    .drawingGroup()
                    .shadow(radius: 1)
            }
        }
        .navigationTitle("navigationbar")
    }

    private var patternHelp: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 30) {

                let tintColor = settingsManager.tintColor.colorAdjusted(colorScheme)

                patternHelp_Section1

                HCenter {
                    Image(systemName: "a.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(tintColor)
                }

                Text("patternshelp3")

                HCenter {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(tintColor)
                }

                Text("patternshelp4")

                Text("patternshelp5")

                HCenter {
                    Image(systemName: "arrowshape.turn.up.forward.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(tintColor)
                }

                Text("patternshelp6")

                Rectangle().frame(height: 20).hidden()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("patterns")
    }

    private var shiftHelp: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                HCenter {
                    Image(systemName: "square.stack.3d.down.forward")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .padding()
                        .background(content: {Color.blue.cornerRadius(12)})
                        .padding()
                        .drawingGroup()
                        .shadow(radius: 1)
                }

                Text("shiftshelp1")

                HCenter {
                    Image("ShiftHeadExample")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                }

                Text("shiftshelp2")

                HCenter {
                    Image("ShiftEditExample")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                }

                Text("shiftshelp3")

                HCenter {
                    ZStack {
                        HStack(spacing: 16) {
                            ShiftView(shift: Shift(shift: "08:00 17:00", gradient_1: Color.hex("ffe259"), gradient_2: Color.hex("ffa751")), cornerRadius: 20)
                                .frame(width: 80, height: 140)
                                .zIndex(1)
                                .offset(x: activateDragAnimation ? 0 : 96)

                            ShiftView(shift: Shift(shift: "09:00 18:00", gradient_1: Color.hex("a8e063"), gradient_2: Color.hex("56ab2f")), cornerRadius: 20)
                                .frame(width: 80, height: 140)
                                .zIndex(2)
                                .offset(x: activateDragAnimation ? 0 : -96)

                            ShiftView(shift: Shift(shift: "07:00 19:00", gradient_1: Color.hex("ff6a00"), gradient_2: Color.hex("ee0979")), cornerRadius: 20)
                                .frame(width: 80, height: 140)
                        }

                        Image(systemName: "hand.tap.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48)
                            .foregroundColor(.primary)
                            .scaleEffect(1.4)
                            .shadow(radius: 2)
                            .padding(.top, 20)
                            .offset(x: activateDragAnimation == true ? 0 : -95)
                    }
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: activateDragAnimation)
                    .task { activateDragAnimation.toggle() }
                }

                Text("shiftshelp4")

                Rectangle().frame(height: 20).hidden()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("shifts")
    }

    @ViewBuilder private var patternHelp_Section1: some View {
        HCenter {
            Image(systemName: "clock.arrow.2.circlepath")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .padding()
                .background(content: {Color.blue.cornerRadius(22)})
                .padding()
                .drawingGroup()
                .shadow(radius: 1)
        }

        Text("patternshelp1")

        HCenter { PatternExample() }

        Text("patternshelp2")
    }

    private var menuExample: some View {
        ZStack {
//            let blur = UIBlurEffect(style: colorScheme == .light ? .extraLight : .dark)
            Rectangle().cornerRadius(16).foregroundColor(colorScheme == .light ? .white : .black).shadow(radius: 5).opacity(0.3)
//            VisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: colorScheme == .light ? .extraLight : .dark)))
//                .cornerRadius(16)
//            VisualEffectView(effect: UIBlurEffect(style: colorScheme == .light ? .extraLight : .dark))
//                .cornerRadius(16)

            VStack(alignment: .leading ,spacing: 6) {
                Rectangle().frame(height: 5).hidden()
                HStack(alignment: .top) {
                    Text("apply")
                        .padding(.bottom, 3)
                        .padding(.leading, 16)
                    Spacer()
                    Image(systemName: "arrowshape.turn.up.forward.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16)
                        .padding(.trailing, 10)
                }
                Rectangle().frame(height: 2).foregroundColor(.gray).opacity(0.2)
                HStack(alignment: .top) {
                    Text("editname")
                        .padding(.bottom, 5)
                        .padding(.leading, 16)
                        .padding(.top, 2)
                    Spacer()
                    Image(systemName: "pencil.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16)
                        .padding(.trailing, 10)
                        .padding(.top, 4)
                }

                Rectangle().frame(height: 2).foregroundColor(.gray).opacity(0.2)
                HStack(alignment: .top) {
                    Text("delete")
                        .foregroundColor(.red)
                        .padding(.bottom, 5)
                        .padding(.leading, 16)
                    Spacer()
                    Image(systemName: "minus.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .frame(width: 16)
                        .padding(.trailing, 10)
                        .padding(.top, 4)
                }

                Rectangle().frame(height: 8).foregroundColor(.gray).opacity(0.4)

                HStack(alignment: .top) {
                    Text("addweek")
                        .padding(.bottom, 5)
                        .padding(.leading, 16)
                    Spacer()
                    Image(systemName: "plus.square.on.square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16)
                        .padding(.trailing, 10)
                        .padding(.top, 4)
                }
                .padding(.bottom, 6)
            }
            .dynamicTypeSize(.medium)
        }
//        .cornerRadius(16)
        .frame(width: 220, height: 160)
    }

}

struct HelpNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        HelpNavigationView()
    }
}
