//
//  GameWidget.swift
//  Tichu
//
//  Created by Leon on 04.06.2026.
//

import WidgetKit
import SwiftUI
import Charts

// MARK: - Shared Models

struct ScorePoint: Identifiable {
    let id = UUID()
    let round: Int
    let value: Int
    let team: String
}

// MARK: - Timeline Entry

struct GameWidgetEntry: TimelineEntry {
    let favorite: Bool
    let id: Int
    let date: Date
    let chartData: [ScorePoint]
    let team1Score: Int
    let team2Score: Int
    let gameDate: Date
}

// MARK: - Provider

struct GameProvider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> GameWidgetEntry {
        GameWidgetEntry(favorite: true, id: 0, date: Date(), chartData: sampleData(), team1Score: 200, team2Score: 150, gameDate: Date())
    }

    func snapshot(for configuration: GameConfigurationAppIntent, in context: Context) async -> GameWidgetEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: GameConfigurationAppIntent, in context: Context) async -> Timeline<GameWidgetEntry> {
        let e = entry(for: configuration)
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        return Timeline(entries: [e], policy: .after(next))
    }

    private func entry(for configuration: GameConfigurationAppIntent) -> GameWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.com.drakynem.tichu")
        let gameId = configuration.game?.id ?? 0
        let gameDate = configuration.game?.date ?? Date()

        guard let data = defaults?.data(forKey: "widgetGames"),
              let games = try? JSONDecoder().decode([WidgetGameData].self, from: data),
              let game = games.first(where: { $0.id == gameId }) else {
            // ✅ game is not available here, use a safe fallback
            return GameWidgetEntry(favorite: false, id: gameId, date: Date(), chartData: sampleData(), team1Score: 0, team2Score: 0, gameDate: gameDate)
        }

        let sorted = game.rounds.filter { $0.boolWinRound }.sorted { $0.roundOrder < $1.roundOrder }

        var t1 = 0, t2 = 0
        var team1Points: [ScorePoint] = [ScorePoint(round: 0, value: 0, team: "Team 1")]
        var team2Points: [ScorePoint] = [ScorePoint(round: 0, value: 0, team: "Team 2")]

        for (i, round) in sorted.enumerated() {
            t1 += round.tichuPointsTeam1 + round.roundPointsTeam1
            t2 += round.tichuPointsTeam2 + round.roundPointsTeam2
            team1Points.append(ScorePoint(round: i + 1, value: t1, team: "Team 1"))
            team2Points.append(ScorePoint(round: i + 1, value: t2, team: "Team 2"))
        }

        return GameWidgetEntry(
            favorite: game.favorite, // ✅ use actual value
            id: gameId,
            date: Date(),
            chartData: team1Points + team2Points,
            team1Score: t1,
            team2Score: t2,
            gameDate: gameDate
        )
    }

    private func sampleData() -> [ScorePoint] {
        let t1 = [0, 110, 195, 310, 400, 530].enumerated().map {
            ScorePoint(round: $0.offset, value: $0.element, team: "Team 1")
        }
        let t2 = [0, 90, 200, 280, 430, 470].enumerated().map {
            ScorePoint(round: $0.offset, value: $0.element, team: "Team 2")
        }
        return t1 + t2
    }
}

// MARK: - Widget View

struct GameWidgetView: View {
    var entry: GameWidgetEntry
    @Environment(\.widgetFamily) var family

    private var yDomain: ClosedRange<Int> {
        let values = entry.chartData.map { $0.value }
        guard let minVal = values.min(), let maxVal = values.max() else { return 0...1000 }
        let padding = max((maxVal - minVal) / 6, 20)
        return (minVal - padding)...(maxVal + padding)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if entry.favorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.secondary)
                }

                Text("\(entry.gameDate, style: .date)")
                    .foregroundStyle(Color.secondary)

                Spacer()
                HStack(spacing: 4) {
                    Text("\(entry.team1Score)")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.accent)
                    Text(":")
                        .font(.headline)
                    Text("\(entry.team2Score)")
                        .font(.headline)
                        .bold()
                }
            }

            Chart(entry.chartData) { point in
                LineMark(
                    x: .value("Round", point.round),
                    y: .value("Score", point.value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(by: .value("Team", point.team))

                PointMark(
                    x: .value("Round", point.round),
                    y: .value("Score", point.value)
                )
                .symbolSize(40)
                .foregroundStyle(by: .value("Team", point.team))
            }
            .chartYScale(domain: yDomain)
            .chartForegroundStyleScale([
                "Team 1": .accent,
                "Team 2": Color.primary
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: 1)) { _ in
                    AxisTick()
                    if family != .systemSmall { AxisValueLabel() }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    if let v = value.as(Int.self) {
                        if family == .systemSmall {
                            AxisValueLabel(String(v % 100 == 0 ? "\(v)" : ""))
                        } else {
                            AxisValueLabel("\(v)")
                        }
                    }
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "tichu://game/\(entry.id)")!)
    }
}

// MARK: - Widget

struct GameWidget: Widget {
    let kind: String = "favGameWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: GameConfigurationAppIntent.self, provider: GameProvider()) { entry in
            GameWidgetView(entry: entry)
        }
        .configurationDisplayName("Favorite Game")
        .description("Graph of your favorite game")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    GameWidget()
} timeline: {
    GameWidgetEntry(
        favorite: true,
        id: 0,
        date: .now,
        chartData: {
            let t1 = [0, 110, 195, 310, 400, 530].enumerated().map {
                ScorePoint(round: $0.offset, value: $0.element, team: "Team 1")
            }
            let t2 = [0, 90, 200, 280, 430, 470].enumerated().map {
                ScorePoint(round: $0.offset, value: $0.element, team: "Team 2")
            }
            return t1 + t2
        }(),
        team1Score: 1000,
        team2Score: 1000,
        gameDate: Date()
    )
}
