//
//  SimpleShiftWidget.swift
//  SimpleShiftWidget
//
//  Created by Ollie on 14/05/2023.
//

import WidgetKit
import SwiftUI
import CoreData


struct Provider: TimelineProvider {
    private var persistenceController = PersistenceController.shared
    private var userCalendar = Calendar.current

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "Placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: "Snapshot")
        completion(entry)
    }

    // Strip date back to Day, Month, Year
    private func getCleanDate(date: Date) -> Date {
        return userCalendar.date(from: userCalendar.dateComponents([.year, .month, .day], from: date))!
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        var testVar = "This is original"

        let now = getCleanDate(date: Date.now)

        testVar = now.description

        let request: NSFetchRequest<CD_Date> = CD_Date.fetchRequest()
        request.sortDescriptors = []
//        request.predicate = NSPredicate(format: "date = %@", now as CVarArg)

        let viewContext = persistenceController.container.viewContext

        do {
            let entities = try viewContext.fetch(request)
            for _ in entities {
                testVar = "We actually got one"
            }
        } catch {
            fatalError()
        }

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, text: testVar)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date

    var text: String
}
struct SimpleShiftWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
//        Text(entry.date, style: .time)
        Text(entry.text)
    }
}

struct SimpleShiftWidget: Widget {
    let kind: String = "SimpleShiftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SimpleShiftWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct SimpleShiftWidget_Previews: PreviewProvider {
    static var previews: some View {
        SimpleShiftWidgetEntryView(entry: SimpleEntry(date: Date(), text: "Preview"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
