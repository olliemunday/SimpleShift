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
    @EnvironmentObject private var viewModel: CalendarPageViewModel
    @EnvironmentObject private var hapticManager: HapticManager

    @Binding var navigationIsScaled: Bool
    @Binding var enableDatePicker: Bool
    @Binding var showDatePicker: Bool
    @Binding var isEditing: Bool
    @Binding var datePickerDate: Date

    // Var to pass to transition as binding if we are moving forward or backwards.
    @Binding var dateForward: Bool

    // Disable dragging & buttons for a time to prevent excessive scrolling
    @State private var disableInput = false

    var visionBar = false

    var body: some View {
        if visionBar {
            visionNavigationBar
        } else {
            navigationBar
        }
    }

    private var visionNavigationBar: some View {
        ZStack {
            navigationDate.zIndex(2)
            visionNavigationButtons.zIndex(3)
        }
        .gesture(dragGesture)
        .animation(.spring, value: dateOffset)
    }

    private var visionNavigationButtons: some View {
        HStack {
            Button(action: { navigationButtonAction(forward: false) },
            label: {
                Label("Back", systemImage: "arrow.left")
            })
            .buttonStyle(.borderedProminent)


            Spacer()

            Button(action: { navigationButtonAction(forward: true) },
            label: {
                Label("Forward", systemImage: "arrow.right")
            })
            .buttonStyle(.borderedProminent)
        }
    }

    // Offset of date text via drag animation.
    @State private var dateOffset: CGSize = CGSize.zero

    // Navigation bar parent.
    private var navigationBar: some View {
        ZStack {
            navigationBackgroundBlur
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
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.65), value: viewModel.calendarPage.display)
        .animation(.spring(), value: dateOffset)
    }

    // Navigation Bar background with Blur view.
    private var navigationBackgroundBlur: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            .background(
                Rectangle()
                    .foregroundColor(viewModel.settingsManager.tintColor.colorAdjusted(colorScheme))
                    .opacity(0.18)

            )
            .cornerRadius(16)
            .shadow(radius: 1)
    }

    // Buttons for Navigation bar.
    private var navigationButtons: some View {
        HStack(spacing: 0) {
            let tintColor = viewModel.settingsManager.tintColor.colorAdjusted(colorScheme)
            let arrowColor = viewModel.settingsManager.tintColor.textColor(colorScheme)
            Button { navigationButtonAction(forward: false) } label: {
                ImageButton(arrow: "arrow.left.circle.fill",
                            size: 40,
                            color: tintColor,
                            imageColor: arrowColor)
            }
            .buttonStyle(.borderless)
            .padding(.leading, 5)

            Spacer()

            Button { navigationButtonAction(forward: true) } label: {
                ImageButton(arrow: "arrow.right.circle.fill",
                            size: 40,
                            color: tintColor,
                            imageColor: arrowColor)
            }
            .padding(.trailing, 5)
        }
    }

    // Function to run for the navigation buttons.
    private func navigationButtonAction(forward: Bool) {
        if disableInput { return }
        dateForward = forward
        disableInput = true
        Task {
            try await Task.sleep(for: .milliseconds(100))
            withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.65)) {
                viewModel.iterateMonth(forward ? 1 : -1)
            }
            try await Task.sleep(for: .milliseconds(800))
            disableInput = false
        }
    }

    // Date display for Navigation bar.
    @ViewBuilder private var navigationDate: some View {
        Text(viewModel.calendarPage.display)
            .id(viewModel.calendarPage.display)
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
                datePickerDate = viewModel.setDate
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
                if enableDatePicker || disableInput { return }
                let width = $0.translation.width
                dateForward = (width > 0 ? false : true)
                dateOffset = CGSize(width: width, height: 0)
            })
            .onEnded({
                // End of drag gesture and long press gesture
                navigationIsScaled = false
                if enableDatePicker || disableInput { return }
                let width = $0.translation.width
                if abs(width) > 80 {
                    dateForward = width > 80 ? false : true
                    disableInput = true
                    Task {
                        try await Task.sleep(for: .milliseconds(100))
                        withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.65)) {
                            viewModel.iterateMonth(dateForward ? 1 : -1)
                        }
                        dateOffset = .zero
                        try await Task.sleep(for: .milliseconds(500))
                        disableInput = false
                    }

                } else {
                    dateOffset = .zero
                }
            })
    }

}

