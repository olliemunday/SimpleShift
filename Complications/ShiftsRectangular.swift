////
////  ShiftsRectangular.swift
////  SimpleShift watchOS Widget
////
////  Created by Ollie on 07/08/2023.
////
//
//import Foundation
//import SwiftUI
//import WidgetKit
//
//struct ShiftsRectangularView : View {
//    var entry: ShiftsProvider.Entry
//    let weekdayUtil = WeekdayUtil()
//
//    let shiftFont = Font.system(size: 18,
//                                weight: .semibold,
//                                design: .rounded)
//
//    let emojiFont = Font.system(size: 32)
//
//    var body: some View {
//        HStack(spacing: 0) {
//            Spacer()
//            todayHeading
//            Spacer()
//            shiftBackground.cornerRadius(14)
//                .overlay( shiftText )
//                .frame(width: 58)
//            Spacer()
//        }
//    }
//
//    private var todayHeading: some View {
//        Text("Shift Today")
//            .bold()
//    }
//
//    private var shiftText: some View {
//        Text(entry.display.shift?.shift ?? String(localized: "off"))
//            .font( entry.display.shift?.isCustom == 2 ? emojiFont : shiftFont)
//            .foregroundStyle(entry.display.shift?.gradient_2.textColor ?? Color.white)
//            .multilineTextAlignment(.center)
//    }
//
//    @ViewBuilder private var shiftBackground: some View {
//        if let shift = entry.display.shift {
//            LinearGradient(colors: [shift.gradient_1,
//                                    shift.gradient_2],
//                           startPoint: UnitPoint.top,
//                           endPoint: UnitPoint.bottom)
//                .drawingGroup()
//        } else {
//            Rectangle()
//                .foregroundStyle(Color("ShiftBackground"))
//        }
//    }
//}
//
//struct ShiftsRectangular: Widget {
//    let kind: String = "ShiftsRectangular"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: ShiftsProvider()) { entry in
//            if #available(watchOS 10.0, *) {
//                TodayRectangularView(entry: entry)
//                    .padding(.vertical, 4)
////                    .padding(.horizontal, 8)
//                    .containerBackground(.fill.tertiary, for: .widget)
//            } else {
//                TodayRectangularView(entry: entry)
//            }
//        }
//        .supportedFamilies([.accessoryRectangular])
//        .configurationDisplayName("Shifts")
//        .description("Show upcoming shifts.")
//        .contentMarginsDisabledIfAvailable()
//    }
//}
//
