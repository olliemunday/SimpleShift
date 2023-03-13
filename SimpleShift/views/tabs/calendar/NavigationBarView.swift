//
//  NavigationBarView.swift
//  SwiftShift
//
//  Created by Ollie on 28/02/2023.
//

import SwiftUI
import UIKit

struct NavigationBarView: View {

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var calendarManager: CalendarManager
    @Binding var navigationIsScaled: Bool
    @Binding var enableDatePicker: Bool
    @Binding var showDatePicker: Bool
    @Binding var isEditing: Bool
    @Binding var datePickerDate: Date

    // State to pass to transition as binding if we are moving forward or backwards.
    @Binding var dateForward: Bool

    // Pass in Haptic function from parent view.
    var playHaptic: (Float, Float, Double) -> ()

    var body: some View {
        navigationSection
    }

    // Offset of date text via drag animation.
    @State private var dateOffset: CGSize = CGSize.zero
    // Navigation bar parent.
    private var navigationSection: some View {
        ZStack {
            navigationBackground
            navigationDate.zIndex(2)
            navigationButtons.zIndex(3)
        }
        .frame(height: 50)
        .padding(.bottom, 6)
        .padding(.top, 2)
        .padding(.horizontal, 10)
        .scaleEffect(navigationIsScaled ? 0.85 : 1.0)
        .onAnimationCompleted(for: navigationIsScaled ? 1.0 : 0.0) {
            if !showDatePicker { enableDatePicker = false }
            if navigationIsScaled {
                playHaptic(1.0, 8, 0.5)
                showDatePicker = true
                navigationIsScaled = false
            }
        }
        .animation(.interactiveSpring(dampingFraction: 0.55).speed(0.7), value: navigationIsScaled)
        .gesture(dragGesture)
        .simultaneousGesture(longPress)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: calendarManager.dateDisplay)
        .animation(.interactiveSpring(response: 0.8, dampingFraction: 0.5), value: dateOffset)
        .onChange(of: calendarManager.dateDisplay, perform: { _ in
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75)) { changeDetect = 1.0 }
        })
        .onAnimationCompleted(for: changeDetect) {
            changeDetect = 0.0
            if showDatePicker { return }
            self.calendarManager.setMonth()
        }
    }
    // Background for Navigation bar.
    private var navigationBackground: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            .cornerRadius(16)
            .shadow(radius: 1)
    }
    // Buttons for Navigation bar.
    private var navigationButtons: some View {
        HStack(spacing: 0) {
            let arrowColor = calendarManager.accentColor == .white ? Color.black : Color.white
            Button { if !showDatePicker { navigationButtonAction(forward: false) } } label: {
                ImageButton(arrow: "arrow.left.circle.fill", size: 40, color: calendarManager.accentColor, imageColor: arrowColor)
            }
            .padding(.leading, 5)

            Spacer()

            Button { if !showDatePicker { navigationButtonAction(forward: true) } } label: {
                ImageButton(arrow: "arrow.right.circle.fill", size: 40, color: calendarManager.accentColor, imageColor: arrowColor)
            }
            .padding(.trailing, 5)
        }
    }
    // Function to run for the navigation buttons. Delay iterating month so dateForward is established else animations can be buggy.
    private func navigationButtonAction(forward: Bool) {
        dateForward = forward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            calendarManager.iterateMonth(value: forward ? 1 : -1)
        })
    }
    // Proxy for text animation. Will be 1.0 when animation is finished.
    @State private var changeDetect = 0.0
    // Date display for Navigation bar.
    @ViewBuilder private var navigationDate: some View {
        Text(calendarManager.dateDisplay)
            .id(calendarManager.dateDisplay)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(size: 32, weight: .semibold, design: .rounded))
            .foregroundColor(Color("ShiftText"))
            .transition(.asymmetric(insertion: .move(edge: dateForward ? .trailing: .leading).combined(with: .opacity), removal: .move(edge: dateForward ? .leading : .trailing).combined(with: .opacity)))
            .offset(dateOffset)
            .drawingGroup()
    }


    // Long press on bar gesture.
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.2)
            .onEnded { _ in
                if showDatePicker { return }
                datePickerDate = calendarManager.setDate
                playHaptic(0.5, 1, 0.3)
                dateOffset = .zero
                navigationIsScaled = true
                enableDatePicker = true
            }
    }

    // Drag on bar gesture.
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({
                if showDatePicker || enableDatePicker { return }
                isEditing = false
                let width = $0.translation.width
                dateForward = (width > 0 ? false : true)
                dateOffset = CGSize(width: width, height: 0)
            })
            .onEnded({
                // End of drag gesture and long press gesture
                let width = $0.translation.width
                dateOffset = .zero
                navigationIsScaled = false
                if showDatePicker || enableDatePicker { return }
                if width > 80 { iterateMonth(forward: false); return }
                if width < -80 { iterateMonth(forward: true); return }
            })
    }
    // Iterate calendarManager month
    private func iterateMonth(forward: Bool) {
        dateForward = forward
        calendarManager.iterateMonth(value: forward ? 1 : -1)
    }
}

