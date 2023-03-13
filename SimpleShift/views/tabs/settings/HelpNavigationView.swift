//
//  HelpNavigationView.swift
//  SwiftShift
//
//  Created by Ollie on 03/03/2023.
//

import SwiftUI

struct HelpNavigationView: View {
    @Environment(\.colorScheme) private var colorScheme


    var body: some View {
        GeometryReader { geo in
            ScrollView {
                Grid(alignment: .center, horizontalSpacing: 35, verticalSpacing: 20) {
                    GridRow(alignment: .center) {
                        NavigationLink(destination: {calendarHelp},
                                       label: { HelpViewOption(image: "calendar", text: String(localized: "calendar")) })

                        NavigationLink(destination: {shiftHelp},
                                       label: { HelpViewOption(image: "square.stack.3d.down.forward", text: String(localized: "shifts")) })

                    }.frame(height: geo.size.height / 4)
                    GridRow {
                        NavigationLink(destination: {patternHelp},
                                       label: { HelpViewOption(image: "clock.arrow.2.circlepath", text: String(localized: "patterns")) })
                    }.frame(height: geo.size.height / 4)
                }
                .padding(.vertical, 20)
                .padding(.horizontal ,35)
            }
        }
        .navigationTitle("help")

    }

    @State var activateDragAnimation: Bool = false
    private var calendarHelp: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 30) {
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
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            activateDragAnimation = true
                        }
                    }
                    .onDisappear { activateDragAnimation = false }
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

                Rectangle().frame(height: 20).hidden()
            }
            .padding(.horizontal, 24)
        }

        .navigationTitle("calendar")

    }

    private var patternHelp: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 30) {

                patternHelp_Section1

                HCenter {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.accentColor)
                }

                Text("patternshelp3")

                HCenter {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.accentColor)
                }

                Text("patternshelp4")

                HCenter { menuExample }

                Text("patternshelp5")

                Rectangle().frame(height: 20).hidden()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("patterns")
    }

    private var shiftHelp: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 30) {
                HCenter {
                    Image(systemName: "square.stack.3d.down.forward")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .padding()
                        .background(content: {Color.blue.cornerRadius(12)})
                        .padding()
                        .drawingGroup()
                        .shadow(radius: 2)
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
                            ShiftView(shift: Shift(shift: "08:00 17:00", gradient_1: Color.hex("ffe259"), gradient_2: Color.hex("ffa751")))
                                .frame(width: 80, height: 140)
                                .zIndex(1)
                                .offset(x: activateDragAnimation ? 0 : 96)

                            ShiftView(shift: Shift(shift: "09:00 18:00", gradient_1: Color.hex("a8e063"), gradient_2: Color.hex("56ab2f")))
                                .frame(width: 80, height: 140)
                                .zIndex(2)
                                .offset(x: activateDragAnimation ? 0 : -96)

                            ShiftView(shift: Shift(shift: "07:00 19:00", gradient_1: Color.hex("ff6a00"), gradient_2: Color.hex("ee0979")))
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
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            activateDragAnimation = true
                        }
                    }
                    .onDisappear { activateDragAnimation = false }
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
                .shadow(radius: 2)
        }

        Text("patternshelp1")

        HCenter { PatternExample() }

        Text("patternshelp2")
    }

    private var menuExample: some View {
        ZStack {
            Rectangle().cornerRadius(16).foregroundColor(colorScheme == .light ? .white : .black).shadow(radius: 5).opacity(0.3)
            VisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: colorScheme == .light ? .extraLight : .dark)))
                .cornerRadius(16)
            VisualEffectView(effect: UIBlurEffect(style: colorScheme == .light ? .extraLight : .dark))
                .cornerRadius(16)

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
