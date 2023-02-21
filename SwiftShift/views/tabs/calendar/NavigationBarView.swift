//
//  NavigationBarView.swift
//  SwiftShift
//
//  Created by Ollie on 03/10/2022.
//

import SwiftUI

struct NavigationBarView: View {
    @EnvironmentObject var calendarManager: CalendarManager

    let playHaptic: (Float, Float, Double) -> ()
    @Binding var enableDatePicker: Bool
    @Binding var showDatePicker: Bool

    // State to pass to transition as binding if we are moving forward or backwards.
    @State var dateForward: Bool = false
    // Offset of date text via drag animation.
    @State var dateOffset: CGSize = CGSize.zero
    // State for if navigation is pressed.
    @State var navigationIsScaled = false

    /// Navigation bottom bar.
    var body: some View {
        ZStack {
            navigationBackground
            navigationDate
            navigationButtons
        }
        .frame(height: 50)
        .padding(.vertical, 6)
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
        .animation(.interactiveSpring(dampingFraction: 0.55).speed(0.5), value: navigationIsScaled)
    }

    /// Background for Navigation Bar.
    private var navigationBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundColor(Color("NavBarBackground"))
            .shadow(radius: 1)
    }

    /// Buttons for Navigation Bar.
    private var navigationButtons: some View {
        HStack(spacing: 0) {
            Button { iterateMonth(forward: false) } label: {
                ImageButton(arrow: "arrow.left.circle.fill", size: 40, color: .blue)
            }
            .padding(.leading, 5)

            Spacer()

            Button { iterateMonth(forward: true) } label: {
                ImageButton(arrow: "arrow.right.circle.fill", size: 40, color: .blue)
            }
            .padding(.trailing, 5)
        }
    }

    /// Date display for Navigation bar.
    private var navigationDate: some View {
        ZStack{
            dateText
        }
        .gesture(dragGesture)
        .simultaneousGesture(longPress)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.75), value: calendarManager.dateViewArray)
    }
    
    /// Date Text View.
    @ViewBuilder private var dateText: some View {
        ForEach(calendarManager.dateViewArray) {
            Text($0.date)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(Color("ShiftText"))
                .transition(AnyTransition.asymmetric(insertion: .flyIn(forward: $dateForward, callback: flyInOutCallback), removal: .flyOut(forward: $dateForward)))
                .animation(.interactiveSpring(dampingFraction: 0.5), value: dateOffset)
                .offset(dateOffset)
                .drawingGroup()
        }
    }

    /// Gestures.
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                if showDatePicker { return }
                playHaptic(0.5, 1, 0.3)
                navigationIsScaled = true
                enableDatePicker = true
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({
                let width = $0.translation.width
                if abs(width) > 5 { showDatePicker = false }
                dateOffset = CGSize(width: width, height: 0)
            })
            .onEnded({
                // End of drag gesture and long press gesture
                let width = $0.translation.width
                if width > 80 { iterateMonth(forward: false) }
                if width < -80 { iterateMonth(forward: true) }
                dateOffset = .zero
                navigationIsScaled = false
                
            })
    }

    /// Convert Date to String for date display.
    private func getDisplayDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMYYYY")

        return dateFormatter.string(from: date)
    }

    private func iterateMonth(forward: Bool) {
        dateForward = forward
        calendarManager.iterateMonth(value: forward ? 1 : -1)
    }

    private func flyInOutCallback() {
        if showDatePicker { return }
        self.calendarManager.setMonth()
    }
    
}
