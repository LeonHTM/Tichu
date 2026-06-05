//
//  TichuWidgets.swift
//  TichuWidgets
//
//  Created by Leon on 03.06.2026.
//

import WidgetKit
import SwiftUI
import AppIntents

struct TichuWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let description: String
    let image: String
    let value: Double
    let percentage: Bool
}

enum playerStat {
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
}



enum TichuStorage {
    static let suite = "group.com.drakynem.tichu"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: suite)
    }

    static func double(_ key: String, default defaultValue: Double = 0) -> Double {
        defaults?.double(forKey: key) ?? defaultValue
    }

    static func string(_ key: String, default defaultValue: String = "") -> String {
        defaults?.string(forKey: key) ?? defaultValue
    }
}



struct Provider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> TichuWidgetEntry {
        TichuWidgetEntry(
            date: Date(),
            title: "Rating",
            description: "All time Rating",
            image: "chart.line.uptrend.xyaxis",
            value: 1000,
            percentage: false
        )
    }

    func snapshot(for configuration: GraphConfigurationAppIntent, in context: Context) async -> TichuWidgetEntry {
        makeEntry(for: configuration)
    }

    func timeline(for configuration: GraphConfigurationAppIntent, in context: Context) async -> Timeline<TichuWidgetEntry> {

        let entry = makeEntry(for: configuration)
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!

        return Timeline(entries: [entry], policy: .after(next))
    }

    private func makeEntry(for configuration: GraphConfigurationAppIntent) -> TichuWidgetEntry {
        var value: Double
        var title: String
        var description: String
        var image: String
        var percentage: Bool
        
        switch configuration.stat {

        case .elo:
            value = TichuStorage.double("userElo")
            title = "Rating"
            description = "All time Rating"
            percentage = false
            image = "chart.line.uptrend.xyaxis"

        case .winnerPercentage:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userWinnerPercentageYear")
            case .month: value = TichuStorage.double("userWinnerPercentageMonth")
            case .week:  value = TichuStorage.double("userWinnerPercentageWeek")
            case .day:   value = TichuStorage.double("userWinnerPercentageDay")
            default:     value = TichuStorage.double("userWinnerPercentage")
            }
            title = "Winner"
            description = "Winning percentage"
            percentage = true
            image = "trophy"

        case .tichuMaster:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userTichuMasterYear")
            case .month: value = TichuStorage.double("userTichuMasterMonth")
            case .week:  value = TichuStorage.double("userTichuMasterWeek")
            case .day:   value = TichuStorage.double("userTichuMasterDay")
            default:     value = TichuStorage.double("userTichuMaster")
            }
            title = "Tichumaster"
            description = "Points from Announcing"
            percentage = false
            image = "number"

        case .visionary:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userVisionaryYear")
            case .month: value = TichuStorage.double("userVisionaryMonth")
            case .week:  value = TichuStorage.double("userVisionaryWeek")
            case .day:   value = TichuStorage.double("userVisionaryDay")
            default:     value = TichuStorage.double("userVisionary")
            }
            title = "Visionary"
            description = "Announced when first"
            percentage = true
            image = "checkmark.circle"

        case .addict:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userAddictYear")
            case .month: value = TichuStorage.double("userAddictMonth")
            case .week:  value = TichuStorage.double("userAddictWeek")
            case .day:   value = TichuStorage.double("userAddictDay")
            default:     value = TichuStorage.double("userAddict")
            }
            title = "Addict"
            description = "Games played"
            percentage = false
            image = "pill"

        case .teamplayer:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userTeamplayerYear")
            case .month: value = TichuStorage.double("userTeamplayerMonth")
            case .week:  value = TichuStorage.double("userTeamplayerWeek")
            case .day:   value = TichuStorage.double("userTeamplayerDay")
            default:     value = TichuStorage.double("userTeamplayer")
            }
            title = "Teamplayer"
            description = "Double-Win Rate"
            percentage = true
            image = "hands.clap"

        case .announcer:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userAnnouncerYear")
            case .month: value = TichuStorage.double("userAnnouncerMonth")
            case .week:  value = TichuStorage.double("userAnnouncerWeek")
            case .day:   value = TichuStorage.double("userAnnouncerDay")
            default:     value = TichuStorage.double("userAnnouncer")
            }
            title = "Announcer"
            description = "Announcement likelyhood"
            percentage = true
            image = "megaphone"

        case .saboteur:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userSaboteurYear")
            case .month: value = TichuStorage.double("userSaboteurMonth")
            case .week:  value = TichuStorage.double("userSaboteurWeek")
            case .day:   value = TichuStorage.double("userSaboteurDay")
            default:     value = TichuStorage.double("userSaboteur")
            }
            title = "Saboteur"
            description = "Tichu prevented rate"
            percentage = true
            image = "xmark.circle"

        case .gambler:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userGamblerYear")
            case .month: value = TichuStorage.double("userGamblerMonth")
            case .week:  value = TichuStorage.double("userGamblerWeek")
            case .day:   value = TichuStorage.double("userGamblerDay")
            default:     value = TichuStorage.double("userGambler")
            }
            title = "Gambler"
            description = "Tichu rate"
            percentage = true
            image = "exclamationmark.circle"

        case .bigGambler:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userBigGamblerYear")
            case .month: value = TichuStorage.double("userBigGamblerMonth")
            case .week:  value = TichuStorage.double("userBigGamblerWeek")
            case .day:   value = TichuStorage.double("userBigGamblerDay")
            default:     value = TichuStorage.double("userBigGambler")
            }
            title = "Big Gambler"
            description = "Big Tichu rate"
            percentage = true
            image = "exclamationmark.2.circle"

        case .pinguGambler:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userPinguGamblerYear")
            case .month: value = TichuStorage.double("userPinguGamblerMonth")
            case .week:  value = TichuStorage.double("userPinguGamblerWeek")
            case .day:   value = TichuStorage.double("userPinguGamblerDay")
            default:     value = TichuStorage.double("userPinguGambler")
            }
            title = "Pingu Gambler"
            description = "Pingu rate"
            percentage = true
            image = "exclamationmark.3.circle"

        case .bomber:
            switch configuration.timeframe {
            case .year:  value = TichuStorage.double("userBomberYear")
            case .month: value = TichuStorage.double("userBomberMonth")
            case .week:  value = TichuStorage.double("userBomberWeek")
            case .day:   value = TichuStorage.double("userBomberDay")
            default:     value = TichuStorage.double("userBomber")
            }
            title = "Bomber"
            description = "Bombs per Round rate"
            percentage = true
            image = "bomb"

        default:
            value = TichuStorage.double("userElo")
            title = "Rating"
            description = "All time Rating"
            percentage = false
            image = "chart.line.uptrend.xyaxis"
        }


        return TichuWidgetEntry(
            date: Date(),
            title: title,
            description: description,
            image: image,
            value: value,
            percentage: percentage
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: GraphConfigurationAppIntent
}

struct TichuWidgetsEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family
    var entry: TichuWidgetEntry

    var valueText: String {
        entry.percentage ? "\(Int(entry.value * 100))%" : "\(Int(entry.value))"
    }

    var body: some View {
        switch family {

        case .systemSmall:
            VStack() {
                HStack {
                    if entry.image == "exclamationmark.2.circle" || entry.image == "bomb" || entry.image == "exclamationmark.3.circle" {
                        Image(entry.image)
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.accent)
                            .frame(width: 20, height: 20)
                        
                    } else {
                        Image(systemName: entry.image)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .scaledToFit()
                            .foregroundStyle(.accent)
                    }
                    Text(entry.title)
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                }.opacity(0.8)
                Spacer()
                HStack {
                    Text(valueText)
                        .font(.system(size: 40, weight: .heavy))
                }
                Spacer()
                Text(entry.description)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
                    .opacity(0.8)
            }
            .containerBackground(.fill.tertiary, for: .widget)
            .widgetURL(URL(string: "tichu://stats")!)

        case .accessoryRectangular:
            
            HStack{
                if entry.image == "exclamationmark.2.circle" || entry.image == "bomb" || entry.image == "exclamationmark.3.circle" {
                    Image(entry.image)
                        .font(.system(size: 32))
                        .symbolVariant(.fill)
                } else {
                    Image(systemName: entry.image)
                        .font(.system(size: 32))
                        .symbolVariant(.fill)
                }
                
                VStack(alignment:.leading){
                    Text(entry.title)
                        .font(.system(size: 13))
                    Text(valueText)
                        .font(.system(size: 20, weight: .heavy))
                    
                }
            }
            .containerBackground(.fill.tertiary, for: .widget)

       

        case .accessoryInline:
            HStack{
                if entry.image == "exclamationmark.2.circle" || entry.image == "bomb" || entry.image == "exclamationmark.3.circle" {
                    Image(entry.image)
                        
                } else {
                    Image(systemName: entry.image)
                       
                }
                if entry.percentage == true {
                    Text("\(entry.title): \(Int(entry.value*100))%")
                }else{
                    Text("\(entry.title): \(Int(entry.value))")
                }
                
            }
            .containerBackground(.fill.tertiary, for: .widget)

        default:
            EmptyView()
        }
    }
}

struct TichuWidgets: Widget {
    let kind: String = "StatWidgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: GraphConfigurationAppIntent.self, provider: Provider()) { entry in
            TichuWidgetsEntryView(entry:entry
            )
        }.configurationDisplayName("Statistics")
            .description("Tichu Statistics of your Choice")
            .supportedFamilies([.systemSmall,.accessoryCircular,
                                .accessoryRectangular,
                                .accessoryInline])
    }
       
}


#Preview(as: .accessoryRectangular) {
    TichuWidgets()
} timeline: {
    TichuWidgetEntry(
        date: .now,
        title: "Big Gambler",
        description: "Success ratio",
        image: "exclamationmark.2.circle",
        value: 0.1,
        percentage: true
    )
}




