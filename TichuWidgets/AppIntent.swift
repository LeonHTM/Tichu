//
//  AppIntent.swift
//  TichuWidgets
//
//  Created by Leon on 03.06.2026.
//

import WidgetKit
import AppIntents

// MARK: - Stats

enum PlayerStat: String, AppEnum {
    case elo
    case winnerPercentage
    case tichuMaster
    case visionary
    case addict
    case teamplayer
    case announcer
    case saboteur
    case gambler
    case bigGambler
    case pinguGambler
    case bomber

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Choose Statistic")

    static var caseDisplayRepresentations: [PlayerStat: DisplayRepresentation] = [
        .elo:              "Elo",
        .winnerPercentage: "Winner Percentage",
        .tichuMaster:      "Tichu Master",
        .visionary:        "Visionary",
        .addict:           "Addict",
        .teamplayer:       "Team Player",
        .announcer:        "Announcer",
        .saboteur:         "Saboteur",
        .gambler:          "Gambler",
        .bigGambler:       "Big Gambler",
        .pinguGambler:     "Pingu Gambler",
        .bomber:           "Bomber"
    ]
}

enum PlayerStatsTimeFrameD: String, AppEnum {
    case allTime
    case year
    case month
    case week
    case day

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Choose Time Frame")

    static var caseDisplayRepresentations: [PlayerStatsTimeFrameD: DisplayRepresentation] = [
        .allTime: "All Time",
        .year:    "Year",
        .month:   "Month",
        .week:    "Week",
        .day:     "Day",
    ]
}

struct GraphConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Choose Statistic" }
    static var description: IntentDescription { "This is an example widget." }

    @Parameter(title: "Statistic", default: .elo)
    var stat: PlayerStat?

    @Parameter(title: "Time Frame", default: .allTime)
    var timeframe: PlayerStatsTimeFrameD?
}

// MARK: - Shared Models

struct WidgetRound: Codable, Identifiable {
    let id: Int
    let roundOrder: Int
    let tichuPointsTeam1: Int
    let tichuPointsTeam2: Int
    let roundPointsTeam1: Int
    let roundPointsTeam2: Int
    let boolWinRound: Bool
}

struct WidgetGameData: Codable {
    let winner: Int?
    var favorite: Bool
    let id: Int
    let date: Date
    let team1Score: Int
    let team2Score: Int
    let rounds: [WidgetRound]
}

// MARK: - Game Entity

struct GameEntity: AppEntity {
    let winner: Int?
    let id: Int
    let date: Date
    let team1Score: Int
    let team2Score: Int
    let favorite: Bool

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Choose Game"
    static var defaultQuery = GameEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        let formatted = date.formatted(date: .numeric, time: .omitted)
        let title = favorite
            ? "\(formatted) (\(team1Score) : \(team2Score)) ★"
            : "\(formatted) (\(team1Score) : \(team2Score))"
        return DisplayRepresentation(
            title: "\(title)",
            /*image: favorite ? .init(systemName: "star.fill") : nil*/
        )
    }
}

struct GameEntityQuery: EntityQuery {
    private func loadGames() -> [GameEntity] {
        guard let data = UserDefaults(suiteName: "group.com.drakynem.tichu")?.data(forKey: "widgetGames"),
              let games = try? JSONDecoder().decode([WidgetGameData].self, from: data) else { return [] }
        return games.map {
            GameEntity(winner: $0.winner,id: $0.id, date: $0.date, team1Score: $0.team1Score, team2Score: $0.team2Score, favorite: $0.favorite)
        }
    }

    func entities(for identifiers: [Int]) async throws -> [GameEntity] {
        loadGames().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [GameEntity] {
        loadGames().filter{$0.favorite == true}.filter{$0.winner != nil}//.sorted { $0.favorite && !$1.favorite }
    }
}

// MARK: - Game Intent

struct GameConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Choose Game" }
    static var description: IntentDescription { "Pick a game to display its score chart." }

    @Parameter(title: "Game")
    var game: GameEntity?
}
