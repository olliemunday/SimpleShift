//
//  NavigationBarView.swift
//  SwiftShift
//
//  Created by Ollie on 28/02/2023.
//

import SwiftUI
import UIKit

struct NavigationBarView: View, Sendable {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var calendarManager: CalendarManager
    @EnvironmentObject private var hapticManager: HapticManager

    @Binding var navigationIsScaled: Bool
    @Binding var enableDatePicker: Bool
    @Binding var showDatePicker: Bool
    @Binding var isEditing: Bool
    @Binding var datePickerDate: Date

    // Var for if we navigation is already changing.
    @State var transitionActive: Bool = false

    // Var for if running on an A11 device.
    @State private var isA11: Bool = false

    // Var to pass to transition as binding if we are moving forward or backwards.
    @Binding var dateForward: Bool

    var body: some View {
        navigationBar

    }

    // Offset of date text via drag animation.
    @State private var dateOffset: CGSize = CGSize.zero

    // Navigation bar parent.
    private var navigationBar: some View {
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
                hapticManager.medium()
                showDatePicker = true
                navigationIsScaled = false
            }
        }
        .animation(.interactiveSpring(dampingFraction: 0.55).speed(0.7), value: navigationIsScaled)
        .gesture(dragGesture)
        .simultaneousGesture(longPress)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: calendarManager.dateDisplay)
        .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.9), value: dateOffset)
        .onAppear(perform: { isA11 = UIDevice.current.modelName.contains("iPhone10") })
    }

    // Background for Navigation bar.
    @ViewBuilder private var navigationBackground: some View {
        if isA11 { navigationBackgroundSimple }
        else { navigationBackgroundBlur }
    }

    // Navigation Bar background with Blur view.
    private var navigationBackgroundBlur: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            .background(
                Rectangle()
                    .foregroundColor(.accentColor)
                    .opacity(0.18)

            )
            .cornerRadius(16)
            .shadow(radius: 1)
    }

    // Navigation Bar background with Rectangle which improves performance on A11.
    private var navigationBackgroundSimple: some View {
        Rectangle()
            .foregroundColor(Color("NavBarBackground"))
            .overlay(content: {
                Rectangle()
                    .foregroundColor(.accentColor)
                    .opacity(0.15)
            })
            .opacity(0.8)
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
        if transitionActive { return }
        dateForward = forward
        transitionActive = true
        Task {
            try await Task.sleep(for: .milliseconds(10))
            await calendarManager.iterateMonth(value: forward ? 1 : -1)
            try await Task.sleep(for: .seconds(1))
            await calendarManager.setMonth()
            transitionActive = false
        }
    }

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
                hapticManager.medium()
                dateOffset = .zero
                navigationIsScaled = true
                enableDatePicker = true
            }
    }

    // Drag on bar gesture.
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({
                if showDatePicker || enableDatePicker || transitionActive { return }
                let width = $0.translation.width
                dateForward = (width > 0 ? false : true)
                dateOffset = CGSize(width: width, height: 0)
            })
            .onEnded({
                // End of drag gesture and long press gesture
                if showDatePicker || enableDatePicker || transitionActive { return }
                let width = $0.translation.width
                dateOffset = .zero
                navigationIsScaled = false

                if abs(width) > 80 {
                    dateForward = width > 80 ? false : true
                    transitionActive = true
                    Task {
                        try await Task.sleep(for: .milliseconds(10))
                        await calendarManager.iterateMonth(value: dateForward ? 1 : -1)
                        try await Task.sleep(for: .seconds(1))
                        await calendarManager.setMonth()
                        transitionActive = false
                    }

                }
            })
    }
    // Iterate calendarManager month
    private func iterateMonth(forward: Bool) {
        dateForward = forward
        calendarManager.iterateMonth(value: forward ? 1 : -1)
    }
}

