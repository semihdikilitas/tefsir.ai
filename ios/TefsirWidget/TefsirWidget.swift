import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct TefsirEntry: TimelineEntry {
    let date: Date
    let verseText: String
    let surahName: String
}

// MARK: - Provider

struct TefsirProvider: TimelineProvider {
    func placeholder(in context: Context) -> TefsirEntry {
        TefsirEntry(
            date: Date(),
            verseText: "Suphesiz guclukle beraber bir kolaylik vardir.",
            surahName: "Insirah Suresi, 5-6"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TefsirEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TefsirEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> TefsirEntry {
        let shared = UserDefaults(suiteName: "group.com.ahmetsemih.islamic_ai_app")
        let verse = shared?.string(forKey: "home_widget.widget_verse_text")
            ?? "\"Suphesiz guclukle beraber bir kolaylik vardir.\""
        let surah = shared?.string(forKey: "home_widget.widget_surah_name")
            ?? "Insirah Suresi, 5-6"

        return TefsirEntry(
            date: Date(),
            verseText: verse,
            surahName: surah
        )
    }
}

// MARK: - Views

struct TefsirWidgetEntryView: View {
    var entry: TefsirEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // Lock screen / Dynamic Island
            lockScreenView
        default:
            homeScreenView
        }
    }

    // Ana ekran widget
    var homeScreenView: some View {
        ZStack {
            Color.black
            VStack(alignment: .trailing, spacing: 6) {
                Spacer()
                Text(entry.verseText)
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .shadow(color: .black, radius: 4)
                Text(entry.surahName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 0.91, green: 0.88, blue: 0.82))
                    .lineLimit(1)
                    .shadow(color: .black, radius: 3)
            }
            .padding(12)
        }
    }

    // Kilit ekrani widget
    var lockScreenView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.verseText)
                .font(.system(size: 12, weight: .medium, design: .serif))
                .italic()
                .foregroundColor(.white)
                .lineLimit(2)
            Text(entry.surahName)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(Color(red: 0.91, green: 0.88, blue: 0.82))
                .lineLimit(1)
        }
    }
}

// MARK: - Widget

@main
struct TefsirWidgetBundle: WidgetBundle {
    var body: some Widget {
        TefsirHomeWidget()
        TefsirLockScreenWidget()
    }
}

struct TefsirHomeWidget: Widget {
    let kind: String = "TefsirWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TefsirProvider()) { entry in
            TefsirWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tefsir AI")
        .description("Gunun ayeti ve duvar kagidi")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TefsirLockScreenWidget: Widget {
    let kind: String = "TefsirLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TefsirProvider()) { entry in
            TefsirWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tefsir AI - Kilit Ekrani")
        .description("Kilit ekraninda gunun ayeti")
        .supportedFamilies([.accessoryRectangular])
    }
}
