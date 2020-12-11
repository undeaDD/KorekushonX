import SwiftUI
import WidgetKit

struct ReminderEntry: TimelineEntry {
    var cover: UIImage
    var date: Date
}

struct ReminderProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReminderEntry {
        ReminderEntry(cover: UIImage(named: "default")!, date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ReminderEntry) -> Void) {
        let entry = ReminderEntry(cover: UIImage(named: "default")!, date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [ReminderEntry] = []
        entries.append(ReminderEntry(cover: UIImage(named: "default")!, date: Date()))

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ReminderEntryView: View {
    var widgetFamily: WidgetFamily
    var entry: ReminderProvider.Entry

    var body: some View {
        if widgetFamily == .systemSmall {
            ZStack {
                GeometryReader { _ in
                    Image(uiImage: entry.cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                ZStack(alignment: .bottom) {
                    Color.clear
                    if let left = Calendar.current.dateComponents([.day], from: Date(), to: entry.date).day {
                        Text("\(left) Days left")
                            .foregroundColor(.white)
                            .font(.system(size: 23, weight: .black))
                            .shadow(color: .black, radius: 5)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                    } else {
                        Text("- Days left")
                            .foregroundColor(.white)
                            .font(.system(size: 23, weight: .black))
                            .shadow(color: .black, radius: 5)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                    }
                }
            }
        } else if widgetFamily == .systemMedium {
            HStack(spacing: 0 ) {
                ZStack {
                    GeometryReader { _ in
                        Image(uiImage: entry.cover)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    ZStack(alignment: .bottom) {
                        Color.clear
                        if let left = Calendar.current.dateComponents([.day], from: Date(), to: entry.date).day {
                            Text("\(left) Days left")
                                .foregroundColor(.white)
                                .font(.system(size: 23, weight: .black))
                                .shadow(color: .black, radius: 5)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        } else {
                            Text("- Days left")
                                .foregroundColor(.white)
                                .font(.system(size: 23, weight: .black))
                                .shadow(color: .black, radius: 5)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        }
                    }
                }
                ZStack {
                    GeometryReader { _ in
                        Image(uiImage: entry.cover)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    ZStack(alignment: .bottom) {
                        Color.clear
                        if let left = Calendar.current.dateComponents([.day], from: Date(), to: entry.date).day {
                            Text("\(left) Days left")
                                .foregroundColor(.white)
                                .font(.system(size: 23, weight: .black))
                                .shadow(color: .black, radius: 5)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        } else {
                            Text("- Days left")
                                .foregroundColor(.white)
                                .font(.system(size: 23, weight: .black))
                                .shadow(color: .black, radius: 5)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ReminderWidget: Widget {
    let kind: String = "ReminderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReminderProvider()) { entry in
            ReminderEntryView(widgetFamily: .systemSmall, entry: entry)
        }
        .configurationDisplayName("Reminder")
        .description("Displays a Countdown ( ? Days left )")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetsPreviewsA: PreviewProvider {
    static var previews: some View {
        ReminderEntryView(widgetFamily: .systemSmall,
            entry: ReminderEntry(cover: UIImage(named: "default")!, date: Date())
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct WidgetsPreviewsB: PreviewProvider {
    static var previews: some View {
        ReminderEntryView(widgetFamily: .systemMedium,
            entry: ReminderEntry(cover: UIImage(named: "default")!, date: Date())
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
