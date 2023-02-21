//
//  SwiftShiftWidget.swift
//  SwiftShiftWidget
//
//  Created by Ollie on 31/10/2022.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    private var widgetManager = WidgetManager()

    func placeholder(in context: Context) -> SimpleEntry {
        let date = Date()
        let dateArray = widgetManager.getWeek()
        return SimpleEntry(date: Date(), calendarDates: [WidgetDateView(id: 0, calendarDate: "1", color: [.blue, .blue], text: date.formatted(date: .omitted, time: .complete))] )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let date = Date()
        let dateArray = widgetManager.getWeek()
        let entry = SimpleEntry(date: Date(), calendarDates: [WidgetDateView(id: 0, calendarDate: "1", color: [.blue, .blue], text: date.formatted(date: .omitted, time: .complete))])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let date = Date()
        let dateArray = WidgetManager().getWeek()

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, calendarDates: dateArray)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var calendarDates = [WidgetDateView]()
}

struct WidgetDateView: Identifiable {
    let id: Int
    let calendarDate: String
    let color: [Color]
    let text: String
}

struct SwiftShiftWidgetEntryView : View {
    var entry: Provider.Entry
    let gridSpacing: CGFloat = 1
    var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 7) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("This Week")
                    .font(.title2)
                    .bold()
                    .padding(.top, 16)
                    .padding(.leading, 16)
                Spacer()
            }
            Spacer()
            week
                .padding(.horizontal, 3)
                .padding(.vertical, 1)
            Spacer()
                .padding(4)
        }
    }

    @ViewBuilder private var week: some View {
        WeekdayBar(weekday: 2, spacing: 1, accentColor: .blue)
            .frame(height: 24)

        shifts
    }

    private var shifts: some View {
        LazyVGrid(columns: gridColumns, alignment: .center, spacing: gridSpacing) {
            ForEach(entry.calendarDates) { date in
                ZStack {
                    GradientRounded(cornerRadius: 12 ,colors: date.color, direction: .vertical)
                    VStack {
                        Text("\(date.calendarDate)")
                            .font(.system(size: 12).bold())
                            .foregroundColor(date.color.first?.textColor)
                        Spacer()
                        Text("\(date.text)")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 16))
                            .foregroundColor(date.color.first?.textColor)
                        Spacer()
                    }
                }
                .drawingGroup()
                .frame(minHeight: 65, idealHeight: 80)
                .shadow(radius: 0)
            }
        }

    }
}

struct SwiftShiftWidget: Widget {
    let kind: String = "SwiftShift"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftShiftWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

struct SwiftShiftWidget_Previews: PreviewProvider {


    static var previews: some View {
        let color = [Color.hex("ff6a00"), Color.hex("ee0979")]
        return SwiftShiftWidgetEntryView(entry: SimpleEntry(date: Date(), calendarDates: [
            WidgetDateView(id: 0, calendarDate: "1", color: color, text: "06:00 14:00"),
            WidgetDateView(id: 1, calendarDate: "2", color: color, text: "06:00 14:00"),
            WidgetDateView(id: 2, calendarDate: "3", color: color, text: "06:00 14:00"),
            WidgetDateView(id: 3, calendarDate: "4", color: color, text: "06:00 14:00"),
            WidgetDateView(id: 4, calendarDate: "5", color: color, text: "06:00 14:00"),
            WidgetDateView(id: 5, calendarDate: "6", color: color, text: "06:00 14:00"),
            WidgetDateView(id: 6, calendarDate: "7", color: color, text: "06:00 14:00")
        ]))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 8")
            .previewContext(WidgetPreviewContext(family: .systemMedium))

    }
}
