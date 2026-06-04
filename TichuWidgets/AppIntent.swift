//
//  AppIntent.swift
//  TichuWidgets
//
//  Created by Leon on 03.06.2026.
//

import WidgetKit
import AppIntents


import AppIntents

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
        .elo: "Elo",
        .winnerPercentage: "Winner Percentage",
        .tichuMaster: "Tichu Master",
        .visionary: "Visionary",
        .addict: "Addict",
        .teamplayer: "Team Player",
        .announcer: "Announcer",
        .saboteur: "Saboteur",
        .gambler: "Gambler",
        .bigGambler: "Big Gambler",
        .pinguGambler: "Pingu Gambler",
        .bomber: "Bomber"
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
        .year: "Year",
        .month: "Month",
        .week: "Week",
        .day: "Day",
       
    ]
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Choose Statistic" }
    static var description: IntentDescription { "This is an example widget." }

    @Parameter(title: "Elo")
    var stat: PlayerStat?
    
    @Parameter(title: "All Time")
    var timeframe: PlayerStatsTimeFrameD?
}
