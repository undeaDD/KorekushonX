import SwiftUI
import WidgetKit

struct RandomEntry: TimelineEntry {
    var title: String
    var cover: UIImage
    var date: Date
}

struct RandomProvider: TimelineProvider {
    func placeholder(in context: Context) -> RandomEntry {
        RandomEntry(title: "Black Bird", cover: UIImage(named: "default")!, date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (RandomEntry) -> Void) {
        let entry = RandomEntry(title: "Black Bird", cover: UIImage(named: "default")!, date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [RandomEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = RandomEntry(title: "Black Bird", cover: UIImage(named: "default")!, date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct RandomEntryView: View {
    var entry: RandomProvider.Entry

    var body: some View {
        ZStack {
            GeometryReader { _ in
                Image(uiImage: UIImage(named: "default")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            ZStack(alignment: .bottom) {
                Color.clear
                Text("Black Bird")
                    .foregroundColor(.white)
                    .font(.system(size: 23, weight: .black))
                    .shadow(color: .black, radius: 5)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            }
        }
    }
}

struct RandomWidget: Widget {
    let kind: String = "RandomWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RandomProvider()) { entry in
            RandomEntryView(entry: entry)
        }
        .configurationDisplayName("Random Manga")
        .description("Displays a random Manga from your Collection")
        .supportedFamilies([.systemSmall])
    }
}

struct WidgetsPreviewsC: PreviewProvider {
    static var previews: some View {
        RandomEntryView(entry: RandomEntry(title: "Black Bird", cover: UIImage(named: "default")!, date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
