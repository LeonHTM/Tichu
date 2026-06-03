    //
    //  GraphWidget.swift
    //  GraphWidget
    //
    //  Created by Leon on 03.06.2026.
    //

    import WidgetKit
    import SwiftUI
    import Charts

    // MARK: - Shared model (must match your app's EloEntry, make it Codable)
    struct EloEntry: Codable, Identifiable {
        let id: Int?
        let eloChange: Double
        let changedAt: Date?
        let gameId: Int?
    }

    struct EloPoint: Identifiable {
        let id = UUID()
        let date: Date
        let elo: Double
    }

    // MARK: - Timeline Entry
    struct EloWidgetEntry: TimelineEntry {
        let date: Date
        let points: [EloPoint]
        let currentElo: Double
    }

    // MARK: - Helpers
    private func userName() -> String {
        UserDefaults(suiteName: "group.com.drakynem.tichu")?.string(forKey: "userName") ?? "Unknown"
    }

    private func userElo() -> Double {
        UserDefaults(suiteName: "group.com.drakynem.tichu")?.double(forKey: "userElo") ?? 1000
    }

    // MARK: - Provider
    struct EloProvider: TimelineProvider {
        func placeholder(in context: Context) -> EloWidgetEntry {
            EloWidgetEntry(date: Date(), points: samplePoints(), currentElo: 1000)
        }

        func getSnapshot(in context: Context, completion: @escaping (EloWidgetEntry) -> Void) {
            completion(entry())
        }

        func getTimeline(in context: Context, completion: @escaping (Timeline<EloWidgetEntry>) -> Void) {
            let e = entry()
            // Refresh every hour
            let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            completion(Timeline(entries: [e], policy: .after(next)))
        }
        
        private func userName() -> String {
            return UserDefaults(suiteName: "group.com.drakynem.tichu")?.string(forKey: "userName") ?? "Unknown"
        }
        
        private func userElo() -> Double {
            return UserDefaults(suiteName: "group.com.drakynem.tichu")?.double(forKey: "userElo") ?? 1000
        }

        private func entry() -> EloWidgetEntry {
            let defaults = UserDefaults(suiteName: "group.com.drakynem.tichu")
            var points: [EloPoint] = []
            var currentElo: Double = 1000

            if let data = defaults?.data(forKey: "eloHistory"),
               let entries = try? JSONDecoder().decode([EloEntry].self, from: data) {
                for e in entries.sorted(by: { ($0.changedAt ?? .distantPast) < ($1.changedAt ?? .distantPast) }) {
                    currentElo += e.eloChange
                    if let date = e.changedAt {
                        points.append(EloPoint(date: date, elo: currentElo))
                    }
                }
            }

            if points.isEmpty {
                points = samplePoints()
                currentElo = 1042
            }

            return EloWidgetEntry(date: Date(), points: points, currentElo: currentElo)
        }

        private func samplePoints() -> [EloPoint] {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            let raw: [(String, Double)] = [
                ("2026-05-03 18:22:10",  12.5),
                ("2026-05-06 20:15:44",  -8.3),
                ("2026-05-09 19:08:33",  15.1),
                ("2026-05-12 21:34:21", -11.2),
                ("2026-05-15 17:45:09",   9.8),
                ("2026-05-18 20:22:55",  -6.4),
                ("2026-05-21 19:11:38",  13.7),
                ("2026-05-24 21:08:47",  -9.1),
                ("2026-05-27 18:33:14",  11.3),
                ("2026-05-30 20:55:02",  -7.6),
                ("2026-06-01 19:44:28",  14.2),
                ("2026-06-02 21:17:53",  -5.9)
            ]

            var elo: Double = 1000

            return raw.compactMap { dateString, change in
                guard let date = formatter.date(from: dateString) else { return nil }
                elo += change
                return EloPoint(date: date, elo: elo)
            }
        }
    }

    // MARK: - Widget View
    struct EloWidgetView: View {
        var entry: EloWidgetEntry
        var userName: String
        var userElo: Double
        @Environment(\.widgetFamily) var family

        
        
        private var yDomain: ClosedRange<Double> {
            let values = entry.points.map { $0.elo }
            guard let minVal = values.min(), let maxVal = values.max() else { return 900...1100 }
            let padding = max((maxVal - minVal) * 0.15, 20)
            return (minVal - padding)...(maxVal + padding)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if family != .systemSmall {
                        Text("\(userName) Rating")
                            .font(.headline)
                            .bold()
                    }else{
                        Text("Elo")
                        
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(Int(userElo))")
                        .font(.headline)
                        .bold()
                }

                Chart(entry.points) { point in

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Elo", point.elo)
                    )
                    //.interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(.accent)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Elo", point.elo)
                    )
                    .symbolSize(40)
                    .foregroundStyle(.accent)
                }
                .chartYScale(domain: yDomain)

                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()

                        if family != .systemSmall {
                            AxisValueLabel(format: .dateTime.day().month())
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()

                        if let elo = value.as(Double.self) {

                            if family == .systemSmall {
                                let lastTwo = Int(elo) % 100
                                AxisValueLabel(String(format: "%02d", lastTwo))
                            } else {
                                AxisValueLabel("\(Int(elo))")
                            }
                        }
                    }
                }
                
            }

            .containerBackground(.fill.tertiary, for: .widget)
            .widgetURL(URL(string: "tichu://elo")!)
        }
    }

    // MARK: - Widget
    struct GraphWidget: Widget {
        let kind: String = "GraphWidgets"

        var body: some WidgetConfiguration {
            StaticConfiguration(kind: kind, provider: EloProvider()) { entry in
                EloWidgetView(entry: entry,userName: userName(), userElo: userElo())
            }
            .configurationDisplayName("Rating History")
            .description("Your Tichu rating over time.")
            .supportedFamilies([.systemSmall, .systemMedium,.systemLarge,.systemExtraLarge])
        }
    }

    // MARK: - Preview
    #Preview(as: .systemSmall) {
        GraphWidget()
    } timeline: {
        EloWidgetEntry(
            date: .now,
            points: (0..<8).map { i in
                EloPoint(
                    date: Calendar.current.date(byAdding: .day, value: -7 + i, to: .now)!,
                    elo: 1000 + Double(i * 12)
                )
            },
            currentElo: 1084
        )
    }

