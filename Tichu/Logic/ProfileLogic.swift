//
//  ProfileLogic.swift
//  Tichu
//
//  Created by Leon on 25.04.2026.
//

import SwiftUI

struct Profile: Identifiable, Equatable, Codable {
    var id: Int
    var name: String?
    var profileImageUrl: String?
    var imageData: Data?

    // Statistics
    var elo: Double?
    var winnerPercentage: Double
    var tichuMaster: Double
    var visionary: Double
    var addict: Double
    var teamplayer: Double
    var announcer: Double
    var saboteur: Double
    var gambler: Double
    var bigGambler: Double
    var pinguGambler: Double
    var bomber: Double

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImageUrl = "profile_image_url"
        case elo
        case winnerPercentage = "winner_percentage"
        case tichuMaster = "tichu_master"
        case visionary, addict, teamplayer, announcer
        case saboteur, gambler
        case bigGambler = "big_gambler"
        case pinguGambler = "pingu_gambler"
        case bomber
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
        case dateAdded
    }

    // Used when creating a new profile before server assigns an id
    init(
        id: Int = 0,
        name: String? = nil,
        email: String? = nil,
        profileImageUrl: String? = nil,
        imageData: Data? = nil,
        date: Date = Date(),
        elo: Double? = nil,
        winnerPercentage: Double = 0.5,
        tichuMaster: Double = 0,
        visionary: Double = 0,
        addict: Double = 0,
        teamplayer: Double = 0,
        announcer: Double = 0,
        saboteur: Double = 0,
        gambler: Double = 0,
        bigGambler: Double = 0,
        pinguGambler: Double = 0,
        bomber: Double = 0
    ) {
        self.id = id
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.imageData = imageData
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
        self.pinguGambler = pinguGambler
        self.bomber = bomber
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        profileImageUrl = try c.decodeIfPresent(String.self, forKey: .profileImageUrl)
        
        elo = try c.decodeIfPresent(Double.self, forKey: .elo)
        winnerPercentage = try c.decodeIfPresent(Double.self, forKey: .winnerPercentage) ?? 50
        tichuMaster = try c.decodeIfPresent(Double.self, forKey: .tichuMaster) ?? 0
        visionary = try c.decodeIfPresent(Double.self, forKey: .visionary) ?? 0
        addict = try c.decodeIfPresent(Double.self, forKey: .addict) ?? 0
        teamplayer = try c.decodeIfPresent(Double.self, forKey: .teamplayer) ?? 0
        announcer = try c.decodeIfPresent(Double.self, forKey: .announcer) ?? 0
        saboteur = try c.decodeIfPresent(Double.self, forKey: .saboteur) ?? 0
        gambler = try c.decodeIfPresent(Double.self, forKey: .gambler) ?? 0
        bigGambler = try c.decodeIfPresent(Double.self, forKey: .bigGambler) ?? 0
        pinguGambler = try c.decodeIfPresent(Double.self, forKey: .pinguGambler) ?? 0
        bomber = try c.decodeIfPresent(Double.self, forKey: .bomber) ?? 0
        // These are local only, never from server
        imageData = nil
    }

    func getStat(for stat: playerStat) -> Double {
        switch stat {
        case .elo: return Double(elo ?? 0)
        case .winnerPercentage: return winnerPercentage
        case .tichuMaster: return tichuMaster
        case .visionary: return visionary
        case .addict: return addict
        case .teamplayer: return teamplayer
        case .announcer: return announcer
        case .saboteur: return saboteur
        case .gambler: return gambler
        case .bigGambler: return bigGambler
        case .pinguGambler: return pinguGambler
        case .bomber: return bomber
        case .dateAdded: return 0
        }
    }

    static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
}


// Function to create sorted Profile list for given DataSet, Stat and sortBy
func makeItems(
            from compareList: [Profile],
            stat: Profile.playerStat,
            sortBy: sortBy.sortBy
        ) -> [Profile] {

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

func makeItems(
    from compareList: [Int],
    stat: Profile.playerStat,
    sortBy: sortBy.sortBy
) -> [Profile] {

    let profiles = NetworkService.shared.profiles.filter {
        compareList.contains($0.id)
    }

    switch sortBy {

    case .valueUp:
        return profiles.sorted {
            $0.getStat(for: stat) < $1.getStat(for: stat)
        }

    case .valueDown:
        return profiles.sorted {
            $0.getStat(for: stat) > $1.getStat(for: stat)
        }

    case .nameUp:
        return profiles.sorted {
            ($0.name ?? "").lowercased() <
            ($1.name ?? "").lowercased()
        }

    case .nameDown:
        return profiles.sorted {
            ($0.name ?? "").lowercased() >
            ($1.name ?? "").lowercased()
        }
    }
}


func makeItems(
    from compareList: [Int],
    stat: Profile.playerStat,
    sortBy: sortBy.sortBy
) -> [Friend] {
    let friends = NetworkService.shared.friends.filter {
        compareList.contains($0.id)
    }
    
    switch sortBy {
    case .valueUp:
        if stat == .dateAdded {
            return friends.sorted { ($0.friendsSince ?? .distantPast) < ($1.friendsSince ?? .distantPast) }
        }
        return friends.sorted { $0.profile.getStat(for: stat) < $1.profile.getStat(for: stat) }
    case .valueDown:
        if stat == .dateAdded {
            return friends.sorted { ($0.friendsSince ?? .distantPast) > ($1.friendsSince ?? .distantPast) }
        }
        return friends.sorted { $0.profile.getStat(for: stat) > $1.profile.getStat(for: stat) }
    case .nameUp:
        return friends.sorted { ($0.profile.name ?? "").lowercased() > ($1.profile.name ?? "").lowercased() }
    case .nameDown:
        return friends.sorted { ($0.profile.name ?? "").lowercased() < ($1.profile.name ?? "").lowercased() }
    }
}



func makeItems(
    from compareList: [Friend],
    stat: Profile.playerStat,
    sortBy: sortBy.sortBy
) -> [Friend] {

    switch sortBy {

    case .valueUp:
        if stat == .dateAdded {
            return compareList.sorted {
                ($0.friendsSince ?? .distantPast) <
                ($1.friendsSince ?? .distantPast)
            }
        }

        return compareList.sorted {
            $0.profile.getStat(for: stat) <
            $1.profile.getStat(for: stat)
        }

    case .valueDown:
        if stat == .dateAdded {
            return compareList.sorted {
                ($0.friendsSince ?? .distantPast) >
                ($1.friendsSince ?? .distantPast)
            }
        }

        return compareList.sorted {
            $0.profile.getStat(for: stat) >
            $1.profile.getStat(for: stat)
        }

    case .nameUp:
        return compareList.sorted {
            ($0.profile.name ?? "").lowercased() <
            ($1.profile.name ?? "").lowercased()
        }

    case .nameDown:
        return compareList.sorted {
            ($0.profile.name ?? "").lowercased() >
            ($1.profile.name ?? "").lowercased()
        }
    }
}


struct Friend: Identifiable, Equatable {
    let id: Int
    let profile: Profile
    let friendsSince: Date?
    
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        lhs.id == rhs.id
    }
}
