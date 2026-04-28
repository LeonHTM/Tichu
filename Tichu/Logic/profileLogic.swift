//
//  profileLogic.swift
//  Tichu
//
//  Created by Leon on 25.04.2026.
//

import SwiftUI

struct profile: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String?
    var imageData: Data?
    var isFriend: Bool

    // Statistics
    var elo: Int?
    var winnerPercentage: Int
    var tichuMaster: Double
    var visionary: Int
    var addict: Int
    var teamplayer: Int
    var announcer: Int
    var saboteur: Int
    var gambler: Int
    var bigGambler: Int
    var bomber: Int

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
        case bomber
    }

    init(
        id: UUID = UUID(),
        name: String? = nil,
        imageData: Data? = nil,
        isFriend: Bool = false,
        elo: Int? = nil,
        winnerPercentage: Int = 50,
        tichuMaster: Double = 0,
        visionary: Int = 0,
        addict: Int = 0,
        teamplayer: Int = 0,
        announcer: Int = 0,
        saboteur: Int = 0,
        gambler: Int = 0,
        bigGambler: Int = 0,
        bomber: Int = 0
    ) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.isFriend = isFriend
        self.elo = elo
        self.winnerPercentage = winnerPercentage
        self.tichuMaster = tichuMaster
        self.visionary = visionary
        self.addict = addict
        self.teamplayer = teamplayer
        self.announcer = announcer
        self.saboteur = saboteur
        self.gambler = gambler
        self.bigGambler = bigGambler
        self.bomber = bomber
    }

    func getStat(for stat: playerStat) -> Double {
        switch stat {
        case .elo:
            return Double(elo ?? 0)

        case .winnerPercentage:
            return Double(winnerPercentage)

        case .tichuMaster:
            return tichuMaster

        case .visionary:
            return Double(visionary)

        case .addict:
            return Double(addict)

        case .teamplayer:
            return Double(teamplayer)

        case .announcer:
            return Double(announcer)

        case .saboteur:
            return Double(saboteur)

        case .gambler:
            return Double(gambler)

        case .bigGambler:
            return Double(bigGambler)

        case .bomber:
            return Double(bomber)
        }
    }

    static func == (lhs: profile, rhs: profile) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - RawRepresentable
extension profile: RawRepresentable {

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(profile.self, from: data) else {
            return nil
        }

        self = value
    }

    var rawValue: String {
        let data = try? JSONEncoder().encode(self)
        return String(data: data ?? Data(), encoding: .utf8) ?? ""
    }
}
        // Function to create sorted profile list for given DataSet, Stat and sortBy
        func makeItems(
            from compareList: [profile],
            stat: profile.playerStat,
            sortBy: sortBy.sortBy
        ) -> [profile] {
            
            switch sortBy {
                
            case .valueUp:
                return compareList.sorted {
                    $0.getStat(for: stat) < $1.getStat(for: stat)
                }
                
            case .valueDown:
                return compareList.sorted {
                    $0.getStat(for: stat) > $1.getStat(for: stat)
                }
                
            case .nameUp:
                return compareList.sorted {
                    ($0.name ?? "").lowercased() > ($1.name ?? "").lowercased()
                }
                
            case .nameDown:
                return compareList.sorted {
                    ($0.name ?? "").lowercased() < ($1.name ?? "").lowercased()
                }
            }
        }
